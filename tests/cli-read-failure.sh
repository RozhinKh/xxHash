#!/bin/sh
set -eu

cleanup() {
    rm -rf .test.read-failure-dir .test.read-failure-file \
        .test.read-failure.xxh .test.read-failure.out .test.read-failure.err
}
trap cleanup EXIT HUP INT TERM

mkdir .test.read-failure-dir
printf 'read failure regression\n' > .test.read-failure-file
./xxhsum .test.read-failure-file > .test.read-failure.xxh
printf '0000000000000000  .test.read-failure-dir\n' | cat - .test.read-failure.xxh > .test.read-failure.xxh.tmp
mv .test.read-failure.xxh.tmp .test.read-failure.xxh

if ./xxhsum --check .test.read-failure.xxh > .test.read-failure.out 2> .test.read-failure.err; then
    echo 'verification unexpectedly succeeded' >&2
    exit 1
fi
grep -F '.test.read-failure-dir' .test.read-failure.out
grep -F '.test.read-failure-file: OK' .test.read-failure.out
grep -F '1 listed file could not be read' .test.read-failure.out

if ./xxhsum --check --status .test.read-failure.xxh > .test.read-failure.out 2> .test.read-failure.err; then
    echo 'status-only verification unexpectedly succeeded' >&2
    exit 1
fi
test ! -s .test.read-failure.out
test ! -s .test.read-failure.err
