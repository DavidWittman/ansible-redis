#!/bin/bash

# parses redis/sentinel output given as pairs of keys and values on separate lines and returns a json object
# usage example: redis-cli --raw -p 26379 sentinel master <mastername> | ./parse_field_value_pairs_array.sh

set -euo pipefail

printf '{\n'
first=1
while read -r key
do
  read -r value

  if [ $first -eq 1 ]; then
    first=0
  else
    printf ',\n'
  fi

  printf '  "%s": "%s"' "$key" "$(echo "$value")"
done
unset first

printf '\n}\n'
