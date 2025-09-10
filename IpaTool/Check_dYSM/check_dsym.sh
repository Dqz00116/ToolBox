#!/bin/bash

echo "============================================"
echo "   iOS dSYM Check Tool (macOS/Linux)"
echo "============================================"

if [ $# -ne 2 ]; then
    echo "Usage: $0 [IPA_OR_MACHO_PATH] [DSYM_PATH]"
    exit 1
fi

python3 "$(dirname "$0")/check_dsym.py" "$1" "$2"
