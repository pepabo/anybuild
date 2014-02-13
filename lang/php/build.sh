#!/bin/bash
# hiroya
#
#  - ./versions.txt からインストールするバージョンとインストールパスを読んでxbuildでインストール
#  - サービス独自のカスタム definitions は PHP_BUILD_DEFINITION_PATH に置いておく

set -x
set -e

cd $( dirname $0 )
test -f versions.txt || exit

export LDFLAGS="-L/usr/lib64/mysql"
export MAKEFLAGS="-j $( getconf _NPROCESSORS_ONLN )"

export PHP_BUILD_DEFINITION_PATH=/usr/local/xbuild/lang/php/definitions/

while read spec; do
    set $(echo $spec)
    version=$1
    install_path=$2

    # build php
    if [ ! -x "$install_path/bin/php" ]; then
        mkdir -p "$install_path"
        /usr/local/xbuild/bin/php-install $spec
    fi

    # install pear modules
    # pearfile なんてものは無いけど、perl の cpanfile の扱いと揃えておく
    for pearfile in "./pearfile" "./pearfile.$( basename $install_path )"; do
        test -f "$pearfile" || continue
        for module in $( grep -v '#' $pearfile ); do
            $install_path/bin/pear list $module 1>/dev/null || sudo $install_path/bin/pear install $module
        done
    done

    # install pecl modules
    for peclfile in "./peclfile" "./peclfile.$( basename $install_path )"; do
        test -f "$peclfile" || continue
        for module in $( grep -v '#' $peclfile ); do
            $install_path/bin/pecl list $module 1>/dev/null || sudo $install_path/bin/pecl install $module
        done
    done
done < versions.txt