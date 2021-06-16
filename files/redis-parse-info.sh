#!/bin/bash

set -euo pipefail

printf '{\n'
first=1
tr -d '\r' | while IFS=':' read key value; do
  case "$key" in
    ""|\#*) continue ;;
  esac

  if [ $first -eq 1 ]; then
    first=0
  else
    printf ',\n'
  fi

  printf '  "%s": "%s"' "$key" "$(echo "$value")"
done
unset first

printf '\n}\n'

