#!/bin/sh
# artemis_bench.sh - run xxHash's throughput benchmark and record custom metrics
# for TurinTech Artemis by writing artemis_results.json to the project root.
set -e

# Locate the built xxhsum binary (Windows produces xxhsum.exe)
if [ -f ./xxhsum.exe ]; then
  BIN=./xxhsum.exe
else
  BIN=./xxhsum
fi

# Run the built-in benchmark (averaged over several iterations for stability)
# and parse the throughput (MB/s) reported for each algorithm into JSON.
"$BIN" -b -i5 2>&1 | tr '\r' '\n' | awk '
  /#XXH/ && /MB\/s/ {
    algo = ""; mbps = ""
    for (i = 1; i <= NF; i++) {
      if ($i ~ /#XXH/)  { t = $i; sub(/^[0-9]*#/, "", t); algo = t }
      if ($i ~ /MB\/s/) { v = $(i-1); gsub(/[()]/, "", v); mbps = v }
    }
    if (algo != "" && mbps != "") { keys[++n] = algo; vals[n] = mbps }
  }
  END {
    printf "{\n"
    for (i = 1; i <= n; i++)
      printf "  \"%s_MBps\": %s%s\n", keys[i], vals[i], (i < n ? "," : "")
    printf "}\n"
  }
' > artemis_results.json

echo "Wrote artemis_results.json:"
cat artemis_results.json
