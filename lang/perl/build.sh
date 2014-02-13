#!/bin/sh
# kuroda
#
#  - ./versions.txt からインストールするバージョンとインストールパスを読んでxbuildでインストール
#  - ./cpanfileがあれば、各perlにcpanmでモジュールをインストール
#  - /cpanfile.<インストールパスのdir名>があればそれも追加でインストール

set -x
set -e

export MAKEFLAGS="-j $( getconf _NPROCESSORS_ONLN )"

cd $( dirname $0 )
yum -y install gcc make
test -f versions.txt || exit

while read spec; do
    set $(echo $spec)
    version=$1
    install_path=$2

    # build perl
    if [ ! -x "$install_path/bin/perl" ]; then
        mkdir -p "$install_path"
        /usr/local/xbuild/bin/perl-install $spec
        # cpanm v1.70はcpanfileの指定がまだできない。githubから開発版をもってくる。
        PATH="$install_path/bin:$PATH" cpanm --notest http://github.com/miyagawa/cpanminus/tarball/1.7102
    fi

    # install modules
    for cpanfile in "./cpanfile" "./cpanfile.$( basename $install_path )"; do
        test -f "$cpanfile" || continue
        PATH="$install_path/bin:$PATH" cpanm --notest --cpanfile "$cpanfile" --installdeps ./
    done
done < versions.txt
