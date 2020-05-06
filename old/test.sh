#!/bin/bash
set -e

which oj > /dev/null || { echo 'ERROR: please install `oj'\'' with: $ pip3 install --user -U online-judge-tools=='\''6.*'\''' >& 1 ; exit 1 ; }

CXX=${CXX:-g++}
CXXFLAGS="${CXXFLAGS:--std=c++14 -O2 -Wall -g}"
ulimit -s unlimited


list-dependencies() {
    file="$1"
    $CXX $CXXFLAGS -I . -MD -MF /dev/stdout -MM "$file" | sed '1s/[^:].*: // ; s/\\$//' | xargs -n 1
}

list-defined() {
    file="$1"
#    $CXX $CXXFLAGS -I . -dM -E "$file"
    echo "list-defined: $file"
    cat "$file"
}

get-url() {
    file="$1"
    list-defined "$file" | grep '^#define PROBLEM ' | sed 's/^#define PROBLEM "\(.*\)"$/\1/'
}

get-error() {
    file="$1"
    list-defined "$file" | grep '^#define ERROR ' | sed 's/^#define ERROR \(.*\)$/\1/'
}

#is-verified() {
#    file="$1"
#    cache=test/timestamp/$(echo -n "$file" | md5sum | sed 's/ .*//')
#    timestamp="$(list-dependencies "$file" | xargs -I '{}' find "$file" '{}' -printf "%T+\t%p\n" | sort -nr | head -n 1 | cut -f 2)"
#    [[ -e $cache ]] && [[ $timestamp -ot $cache ]]
#}
is-verified() {
    dir="$1"
    checksum=$dir/checksum.txt
    md5=`md5sum -b $dir/"a.out" | awk '{ print $1 }'`
    if [ -e $checksum ]; then
        old_md5=`cat $checksum`
        if [[ $md5 == $old_md5 ]]; then
            true
        else
            false
        fi
    else
        false
    fi
}


#mark-verified() {
#    file="$1"
#    cache=test/timestamp/$(echo -n "$file" | md5sum | sed 's/ .*//')
#    mkdir -p test/timestamp
#    touch $cache
#}
mark-verified() {
    echo "mark verified"
    dir="$1"
    checksum=$dir/checksum.txt
    md5=`md5sum -b $dir/"a.out" | awk '{ print $1 }'`
    echo $md5 > $checksum
}


list-recently-updated() {
#    for file in $(find . -name \*.test.cpp) ; do
    for file in $(find . -name \*_test.nim) ; do
        list-dependencies "$file" | xargs -n 1 | while read f ; do
            git log -1 --format="%ci    ${file}" "$f"
        done | sort -nr | head -n 1
    done | sort -nr | head -n 20 | cut -f 2
}

run() {
    file="$1"
    url="$(get-url "$file")"
    error="$(get-error "$file")"
#    dir=test/$(echo -n "$url" | md5sum | sed 's/ .*//')
    bin_dir=$(pwd)/test/bin/$(echo -n $(basename "$file"))
    oj_dir="None"
    if [[ $url == http://judge.u-aizu.ac.jp* ]]; then
        oj_dir="aoj"
        id=${url##*id=}
#        return
    elif [[ $url == https://judge.yosupo.jp* ]]; then
        oj_dir="yosupo"
        id=${url##*problem/}
#        return
    else
        echo "WARNING!!!! NO OBJ DIR"
        exit;
    fi

    mkdir -p ${bin_dir}
    test_dir="$(pwd)/test/case/$oj_dir/$id"

    # ignore if IGNORE is defined
    if list-defined "$file" | grep '^#define IGNORE ' > /dev/null ; then
        return
    fi
#    nim c -d:release --warnings:off -o:${bin_dir}/a.out "$file"
    nim cpp --cc=gcc -d:release --warnings:off -o:${bin_dir}/a.out "$file"
#    nim cpp --cc=gcc -d:debug -o:${bin_dir}/a.out "$file"
#    if ! is-verified "$file" ; then
    if ! is-verified "$bin_dir" ; then
        # compile
#        $CXX $CXXFLAGS -I . -o ${dir}/a.out "$file"
#        echo "dir: ${dir}"
        if [[ -n ${url} ]] ; then
            echo "run"
            # download
            if [[ ! -e ${test_dir} ]] ; then
                sleep 2
                oj download --system "$url" -d ${test_dir}
            fi
            echo "test"
            # test
#            oj test -c ${dir}/a.out -d ${test_dir} --special-judge ${test_dir}/judge.py
            if [ -n "$error" ]; then
                oj test -c ${bin_dir}/a.out -d ${test_dir} -e ${error}
            else
                oj test -c ${bin_dir}/a.out -d ${test_dir}
            fi
        else
            # run
            ${bin_dir}/a.out
        fi
        mark-verified "$bin_dir"
    fi
}


if [[ $# -eq 1 && ( $1 = -h || $1 = --help || $1 = -? ) ]] ; then
    echo Usage: $0 '[FILE ...]'
    echo 'Compile and Run specified C++ code.'
    echo 'If the given code contains macro like `#define PROBLEM "https://..."'\'', Download test cases of the problem and Test with them.'
    echo
    echo 'Features:'
    echo '-   glob files with "**/*.test.cpp" if no arguments given.'
    echo '-   cache results of tests, analyze "#include <...>" relations, and execute tests if and only if necessary.'
    echo '-   on CI environment (i.e. $CI is defined), only recently modified files are tested (without cache).'

elif [[ $# -eq 0 ]] ; then
#    if [[ $CI ]] ; then
#        # CI
#        for f in $(list-recently-updated) ; do
#            run $f
#        done
#
#    else
        # local
#        for f in $(find . -name \*.test.cpp) ; do
        for f in $(find . -name \*_test.nim -type f) ; do
#            if [ "`echo $f | grep intersection_of_circle_and_polygon`" ]; then
#                continue
#            fi
            run $f
        done
#    fi
else
    # specified
    for f in "$@" ; do
        run "$f"
    done
fi
