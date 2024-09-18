#!/usr/bin/env bash

# Apply sed on esa.io post body.
#
# USage:
#   ./esa-findgrepsed.sh <personal access token> <team name> <keyword> <replacement> [--dry-run] [-n]

set -euo pipefail

# Use -z for mac bash compatibility
# https://stackoverflow.com/a/13864829/4006322
if [ -z ${1+x} ]; then
  echo 'Please give `Personal access tokens`.' >&2
  exit 1
else
  pat=$1
fi

if [ -z ${2+x} ]; then
  echo 'Please give team name.' >&2
  exit 1
else
  team_name=$2
fi

if [ -z ${3+x} ]; then
  echo 'Please give keyword' >&2
  exit 1
else
  keyword=$3
fi

if [ -z ${4+x} ]; then
  echo 'Please give replacement' >&2
  exit 1
else
  replacement=$4
fi

shift 4

dry_run=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
        dry_run=true
        shift
        ;;
    -n)
        dry_run=true
        shift
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
  esac
done

cd "$(dirname "$0")"

while read -f post_number; do
  ./esa-sed.sh $pat $team_name $post_number 's///g'
done <(./esa-findgrep.sh $pat $team_name $keyword)
