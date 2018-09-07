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
        # generate if there is at least one .adoc file in given dir
        if [ `find $dir -type f -maxdepth 1 -name \*.adoc | wc -l` -ne 0 ]; then
            generateDocs;
        fi
    done
}

# generate .html file from .adoc file in given dir using asciidoctor
function generateDocs() {
    in=/documents/$dir/*.adoc
    out=/documents/output/$dir
    docker run -v $WORK_DIR:/documents/ --name asciidoc-to-html asciidoctor/docker-asciidoctor asciidoctor -D $out $in
    docker rm asciidoc-to-html
}

# copy all files (other than .adoc file) from 'docs' dir to 'output'
function copyAll() {
    for dir in `find docs -type d`
    do
        sudo mkdir -p output/$dir
        for file in `find $dir -maxdepth 1 -type f ! -name "*.adoc"`
        do
            sudo cp $file output/$dir
        done
    done
}

# rename .adoc link to .html in index.html file
function renameLinks() {
    docker run -v $WORK_DIR:/documents/ --name asciidoc-to-html asciidoctor/docker-asciidoctor sed -i 's/.[aA][dD][oO][cC]/.html/g' /documents/output/docs/index.html
    docker rm asciidoc-to-html
}

run;
