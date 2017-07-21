#!/usr/bin/env bash

sourceDir=./src/images/
publicDir=./public/images/
minutes=${1:-5}

# find all png files from $sourceDir modified in last $minutes minutes
find ${sourceDir} -name "*.png" -mmin -${minutes} | while read f ; do
    src=$f
    dest=$(echo $f | sed -e "s#"$sourceDir"#"$publicDir"#g")
    # remove last optimized file
    rm -rf $dest
    # optimize file with optipng and save to $publicDir
    optipng $src -out $dest
done
