#!/bin/sh

set -eu

# A missing --seed operand must be rejected, not dereferenced as a NULL argv.
if ./xxhsum --seed > .test.seed.out 2> .test.seed.err; then
    echo "xxhsum unexpectedly accepted --seed without a value" >&2
    exit 1
fi

# Preserve valid seeded operation for both seed widths.
printf 'seed regression\n' > .test.seed.input
./xxhsum -H32 --seed 1 .test.seed.input > .test.seed.32
./xxhsum -H64 --seed 1 .test.seed.input > .test.seed.64
./xxhsum -c .test.seed.32
./xxhsum -c .test.seed.64

rm -f .test.seed.out .test.seed.err .test.seed.input .test.seed.32 .test.seed.64

echo OK
