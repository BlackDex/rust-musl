#!/usr/bin/env python3
# update_libs.py
# pylint: disable=line-too-long,missing-function-docstring,missing-module-docstring
#
# Retrieve the versions of packages from Arch Linux's (inc. AUR) and Alpine's repositories.
# Also try to extract versions from some download sites like basic mirrors.
#
# The code in documentation comments can also be used to test the functions by
# running "python -m doctest update_libs.py -v".
#   The "str" call is only needed to make the test pass on Python, you
#   do not need to include it when using this function.

import re
import requests
import toml

from natsort import natsorted

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 'en-US,en;q=0.9',
    'Cache-Control': 'no-cache',
    'Pragma': 'no-cache',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
    'Sec-Ch-Ua-Mobile': '?0',
    'Sec-Ch-Ua-Platform': 'Linux',
    'Sec-Ch-Ua': "\"Not)A;Brand\";v=\"8\", \"Chromium\";v=\"138\", \"Google Chrome\";v=\"138\"",
}

SESSION = requests.Session()
SESSION.headers.update(HEADERS)

def convert_sqlite_version(ver: str):
    """Convert SQLite package versions to match upstream's format

    >>> convert_sqlite_version('3.39.3')
    '3390300'
    >>> convert_sqlite_version('3_39_3')
    '3390300'
    """

    return ver.replace("_", ".")
    # matches = re.match(r'(\d+)[\._](\d+)[\._](\d+)', ver)
    # return f'{int(matches.group(1)):d}{int(matches.group(2)):02d}{int(matches.group(3)):02d}00'


def pkgver(package: str):
    """Retrieve the current version of the package in Arch Linux repos
    API documentation: https://wiki.archlinux.org/index.php/Official_repositories_web_interface

    >>> str(pkgver('zlib'))
    '1.3.1'
    """

    # Though the URL contains "/search/", this only returns exact matches (see API documentation)
    url = f'https://www.archlinux.org/packages/search/json/?name={package}'
    with SESSION.get(url, stream=False, timeout=(2, 3)) as res:
        metadata = res.json()


    try:
        return metadata['results'][0]['pkgver']
    except IndexError:
        return 'Package not found'


def aurver(package: str):
    """Retrieve the current version of the package in AUR Arch Linux repos
    API documentation: https://wiki.archlinux.org/title/Aurweb_RPC_interface

    >>> str(aurver('mariadb-connector-c'))
    '3.3.7'
    """

    url = f'https://aur.archlinux.org/rpc/?v=5&type=info&arg[]={package}'
    with SESSION.get(url, stream=False, timeout=(2, 3)) as res:
        metadata = res.json()

    try:
        return metadata['results'][0]['Version'].rsplit('-', 1)[0]
    except IndexError:
        return 'Package not found'


def alpinever(package: str):
    """Retrieve the current version of the package in Alpine repos

    >>> str(alpinever('mariadb-connector-c'))
    '3.4.6'
    """

    try:
        url = f'https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/main/{package}/APKBUILD'
        max_bytes = 1024
        chunks: list[str] = []
        seen = 0

        with SESSION.get(url, stream=True, timeout=(2, 3)) as res:
            res.raise_for_status()
            if not res.encoding:
                res.encoding = 'utf-8'

            for chunk in res.iter_content(chunk_size=max_bytes, decode_unicode=True):
                if not chunk:
                    break
                chunks.append(chunk)
                seen += len(chunk)
                if seen >= max_bytes:
                    break

            apkbuild = ''.join(chunks)[:max_bytes]

        matches = re.search(r'pkgver=(.*)\n', apkbuild, re.MULTILINE)
        return f'{matches.group(1)}'
    except requests.exceptions.RequestException:
        return 'Package not found'


def mirrorver(site: str, href_prefix: str, strip_prefix: str | None = None, re_postfix: str | None =r'[\/]?\"'):
    # pylint: disable=anomalous-backslash-in-string
    """Retrieve the current version of the package in Alpine repos
    >>> str(mirrorver('https://archive.mariadb.org/?C=M&O=D', r'connector-c-3\\.3\\.', 'connector-c-', r'\\/'))
    '3.3.8'

    >>> str(mirrorver('https://www.sqlite.org/chronology.html', r'releaselog\\/\\d_\\d+\\_\\d+', r'releaselog/', r'\\.html'))
    '3_46_0'
    """

    try:
        cache_key = f'cached_data_{site}'
        if not hasattr(mirrorver, cache_key):
            max_bytes = 20480
            chunks: list[str] = []
            seen = 0

            with SESSION.get(site, stream=True, timeout=(2, 3)) as res:
                res.raise_for_status()
                if not res.encoding:
                    res.encoding = 'utf-8'

                for chunk in res.iter_content(chunk_size=4096, decode_unicode=True):
                    if not chunk:
                        break
                    chunks.append(chunk)
                    seen += len(chunk)
                    if seen >= max_bytes:
                        break

                site_data = ''.join(chunks)[:max_bytes]
                setattr(mirrorver, cache_key, site_data)

        site_html = getattr(mirrorver, cache_key)
        matches_raw = re.findall(fr'href=\"({href_prefix}.*?){re_postfix}', site_html, re.MULTILINE)
        matches: list[str] = []
        for match in matches_raw:
            if isinstance(match, tuple):
                matches.append(match[len(match)-1])
            elif isinstance(match, str):
                matches.append(match)

        latest_version = natsorted(matches).pop().replace(strip_prefix, '')
        return f'{latest_version}'
    except requests.exceptions.RequestException:
        return 'Package not found'
    except IndexError:
        return 'No version found'


def githubver(repo: str, version_filter: str = r'.*', strip_prefix: str | None = None):
    """Retrieve the current version of the package based upon tags from github

    >>> str(githubver('openssl/openssl', r'3\\.0\\.', r'openssl-'))
    '3.0.15'
    """

    try:
        url = f'https://api.github.com/repos/{repo}/tags?per_page=50'
        cache_key = f'cached_data_{url}'
        if not hasattr(githubver, cache_key):
            with SESSION.get(url, stream=False, timeout=(2, 3)) as res:
                setattr(githubver, cache_key, res.json())

        metadata = getattr(githubver, cache_key)

        matches = [item['name'] for item in metadata if re.search(version_filter, item['name'])]
        latest_version = natsorted(matches).pop().replace(strip_prefix, '')
        return f'{latest_version}'
    except requests.exceptions.RequestException:
        return 'Package not found'
    except IndexError:
        return 'No version found'


def rustup_version():
    """
    Retrieve the current version of Rustup from https://static.rust-lang.org/rustup/release-stable.toml

    :return: The current Rustup version

    >>> str(rustup_version())
    '1.27.1'
    """

    with SESSION.get('https://static.rust-lang.org/rustup/release-stable.toml', stream=False, timeout=(2, 3)) as res:
        metadata = toml.loads(res.text)

    return metadata['version']


def libxml2ver(site: str):
    """Retrieve the current version of libmxl2

    >>> str(libxml2ver('https://download.gnome.org/sources/libxml2/cache.json'))
    '2.12.7'
    """

    with SESSION.get(site, stream=False, timeout=(2, 3)) as res:
        metadata = res.json()

    try:
        versions = metadata[2]['libxml2']
        latest_version = natsorted(versions).pop()
        return f'{latest_version}'
    except IndexError:
        return 'libxml2 versions not found'


if __name__ == '__main__':
    PACKAGES: dict[str, str] = {
        # Print the latest versions available from there main mirrors/release-pages
        'ZLIB': mirrorver('https://zlib.net/', r'zlib-\d\.\d+', r'zlib-', r'\.tar\.gz'),
        'SSL': githubver('openssl/openssl', r'openssl-3\.5\..*', r'openssl-'),
        'CURL': mirrorver('https://curl.se/download/', r'download\/curl-[89]\.\d+\.\d+', r'download/curl-', r'\.tar\.xz'),
        'SCCACHE': githubver('mozilla/sccache', r'v\d\..*', r'v'),
        'PQ_15': mirrorver('https://ftp.postgresql.org/pub/source/', r'v15\.', 'v'),
        'PQ_16': mirrorver('https://ftp.postgresql.org/pub/source/', r'v16\.', 'v'),
        'PQ_17': mirrorver('https://ftp.postgresql.org/pub/source/', r'v17\.', 'v'),
        'PQ_18': mirrorver('https://ftp.postgresql.org/pub/source/', r'v18\.', 'v'),
        'SQLITE': convert_sqlite_version(mirrorver('https://www.sqlite.org/chronology.html', r'releaselog\/\d_\d+\_\d+', r'releaselog/', r'\.html')),
        'MARIADB': mirrorver('https://archive.mariadb.org/?C=M&O=D', r'connector-c-3\.4\.+', 'connector-c-', r'\/'),
        # 'MYSQL': mirrorver('https://dev.mysql.com/downloads/mysql/?tpl=files&os=src&version=8.4', r'\/downloads\/gpg\/\?file=mysql-8.4', r'/downloads/gpg/?file=mysql-', r'\.tar\.gz.*'),
        'LIBXML2': githubver('GNOME/libxml2', r'v2\..*', r'v'),
        # Also print some other version or from other resources just to compare
        '---': '---',
        'SSL3_X': githubver('openssl/openssl', r'openssl-.*', r'openssl-'),
        'SSL3_3': githubver('openssl/openssl', r'openssl-3\.3\..*', r'openssl-'),
        'SSL_ARCH': pkgver('openssl'),
        'CURL_ARCH': pkgver('curl'),
        'ZLIB_ARCH': pkgver('zlib'),
        'RUSTUP': rustup_version(),
        'PQ_ARCH': pkgver('postgresql'),
        'PQ_ALPINE': alpinever('postgresql17'),
        'SQLITE_ARCH': convert_sqlite_version(pkgver('sqlite')),
        'MARIADB_3_X': mirrorver('https://archive.mariadb.org/?C=M&O=D', r'connector-c-3\.\d+\.', 'connector-c-', r'\/'),
        'MARIADB_ALPINE': alpinever('mariadb-connector-c'),
        'LIBXML2_ARCH': pkgver('libxml2'),
        'LIBXML2_ALPINE': alpinever('libxml2'),
    }

    # Show a list of packages with current versions
    for pkg, version in PACKAGES.items():
        if pkg == '---':
            print(f'{pkg}')
        else:
            print(f'{pkg}="{version}"')
