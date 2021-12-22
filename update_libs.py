#!/usr/bin/env python3
# update_libs.py
#
# Retrieve the versions of packages from Arch Linux's repositories and update
# Dockerfile as needed.
#
# The code in documentation comments can also be used to test the functions by
# running "python -m doctest update_libs.py -v".
#   The "str" call is only needed to make the test pass on Python, you
#   do not need to include it when using this function.

#from __future__ import print_function

import urllib.request as urllib
import json
import toml
import re


def convert_openssl_version(version):
    """Convert OpenSSL package versions to match upstream's format

    >>> convert_openssl_version('1.1.1.k')
    '1.1.1k'
    """

    return re.sub(r'(.+)\.([a-z])', r'\1\2', version)


def convert_sqlite_version(version):
    """Convert SQLite package versions to match upstream's format

    >>> convert_sqlite_version('3.36.1')
    '3360100'
    """

    matches = re.match(r'(\d+)\.(\d+)\.(\d+)', version)
    return '{:d}{:02d}{:02d}00'.format(int(matches.group(1)), int(matches.group(2)), int(matches.group(3)))


def pkgver(package):
    """Retrieve the current version of the package in Arch Linux repos
    API documentation: https://wiki.archlinux.org/index.php/Official_repositories_web_interface

    >>> str(pkgver('zlib'))
    '1.2.11'
    """

    # Though the URL contains "/search/", this only returns exact matches (see API documentation)
    url = 'https://www.archlinux.org/packages/search/json/?name={}'.format(package)
    req = urllib.urlopen(url)
    metadata = json.loads(req.read())
    req.close()
    try:
        return metadata['results'][0]['pkgver']
    except IndexError:
        raise NameError('Package not found: {}'.format(package))


def aurver(package):
    """Retrieve the current version of the package in AUR Arch Linux repos
    API documentation: https://wiki.archlinux.org/title/Aurweb_RPC_interface

    >>> str(aurver('postgresql-11'))
    '11.12'
    """

    # Though the URL contains "/search/", this only returns exact matches (see API documentation)
    url = 'https://aur.archlinux.org/rpc/?v=5&type=info&arg[]={}'.format(package)
    req = urllib.urlopen(url)
    metadata = json.loads(req.read())
    req.close()
    try:
        return metadata['results'][0]['Version'].rsplit('-', 1)[0]
    except IndexError:
        raise NameError('Package not found: {}'.format(package))


def alpinever(package):
    """Retrieve the current version of the package in Alpine repos

    >>> str(alpinever('mariadb-connector-c'))
    '3.1.13'
    """

    # Though the URL contains "/search/", this only returns exact matches (see API documentation)
    url = 'https://git.alpinelinux.org/aports/plain/main/{}/APKBUILD'.format(package)
    req = urllib.urlopen(url)
    apkbuild = req.read(1024).decode('utf-8')
    req.close()
    try:
        matches = re.search(r'pkgver=(.*)\n', apkbuild, re.MULTILINE)
        return '{}'.format(matches.group(1))
    except:
        raise NameError('Package not found: {}'.format(package))


def rustup_version():
    """
    Retrieve the current version of Rustup from https://static.rust-lang.org/rustup/release-stable.toml

    :return: The current Rustup version
    """

    req = urllib.urlopen('https://static.rust-lang.org/rustup/release-stable.toml')
    metadata = toml.loads(req.read().decode("utf-8"))
    req.close()

    return metadata['version']


if __name__ == '__main__':
    PACKAGES = {
        'SSL': convert_openssl_version(pkgver('openssl')),
        'CURL': pkgver('curl'),
        'ZLIB': pkgver('zlib'),
        'PQ': aurver('postgresql-11'),
        'SQLITE': convert_sqlite_version(pkgver('sqlite')),
        'MARIADB': alpinever('mariadb-connector-c'),
        '---': '---',
        'PQ_12': aurver('postgresql-12'),
        'PQ_LATEST': pkgver('postgresql'),
        'RUSTUP': rustup_version()
    }

    # Show a list of packages with current versions
    for prefix in PACKAGES:
        if prefix == '---':
            print('{}'.format(prefix))
        else:
            print('{}_VER="{}"'.format(prefix, PACKAGES[prefix]))

    # # Open a different file for the destination to update Dockerfile atomically
    # src = open('Dockerfile', 'r')
    # dst = open('Dockerfile.new', 'w')

    # # Iterate over each line in Dockerfile, replacing any *_VER variables with the most recent version
    # for line in src:
    #     for prefix in PACKAGES:
    #         version = PACKAGES[prefix]
    #         line = re.sub(r'({}_VER=)\S+'.format(prefix), r'\1"{}"'.format(version), line)
    #     dst.write(line)

    # # Close original and new Dockerfile then overwrite the old with the new
    # src.close()
    # dst.close()
    # os.rename('Dockerfile.new', 'Dockerfile')
