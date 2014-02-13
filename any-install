#!/bin/sh
# kuroda

cd $( dirname $0 )

set -x
set -e

lang_server=$( cat .lang_server )

if [ -n "$lang_server" ]; then
    echo "$lang_server からビルド済みデータを取得..."
    ./sync_lang --pull --delete
fi

for builder in $( ls lang/*/build.sh ); do
    ./$builder
done

if [ -n "$lang_server" ]; then
    echo "ビルドしたものを $lang_server に同期..."
    ./sync_lang --push
fi
