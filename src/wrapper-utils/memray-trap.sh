#!/bin/bash
memray_arg="$1"
cmd="python -m memray run --output memray-report.bin -m $memray_arg"

echo "Running profiler process: $cmd"
eval "$cmd"
exit_code=$?

echo "Memray process ended with exit code $exit_code"
python -m memray stats memray-report.bin

echo "Running server in normal mode"
eval "python -u -m $memray_arg"
