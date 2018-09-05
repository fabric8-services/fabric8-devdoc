#!/bin/bash

function run() {
    WORK_DIR=$PWD
    if [ "$TRAVIS_ENABLED" = true ]; then
        WORK_DIR=$TRAVIS_BUILD_DIR
    fi

    init;
    generateAll;
    copyAll;
    renameLinks;
}

function init() {
    set -x
    set -e

    rm -rf output
    mkdir -p output

    docker pull asciidoctor/docker-asciidoctor
}

function generateAll() {
    for dir in `find docs -type d`
    do
        cnt=`find $dir -type f -maxdepth 1 -name \*.adoc | wc -l`
        if [ ${cnt} -ne 0 ]; then
            generateDocs;
        fi
    done
}

function generateDocs() {
    in=/documents/$dir/*.adoc
    out=/documents/output/$dir
    docker run -v $WORK_DIR:/documents/ --name asciidoc-to-html asciidoctor/docker-asciidoctor asciidoctor -D $out $in
    docker rm asciidoc-to-html
}

function copyAll() {
    for dir in `find docs -type d`
    do
        mkdir -p output/$dir
        for file in `find $dir -maxdepth 1 -type f ! -name "*.adoc"`
        do
            cp $file output/$dir
        done
    done
}

function renameLinks() {
    sed -i 's/.[aA][dD][oO][cC]/.html/g' output/docs/index.html
}

run;
