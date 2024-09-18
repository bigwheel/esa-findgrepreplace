#!/usr/bin/env bash

# Replace keyword on all pages.
#
# USage:
#   ./esa-findgrepreplace.sh <personal access token> <team name> <keyword> <replacement> [--dry-run] [-n] [--sleep-sec=<sleep second>]

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
sleep_sec=25
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
    --sleep-sec=*)
        sleep_sec="${1#*=}"
        shift
        ;;
    --sleep-sec)
        sleep_sec="$2"
        shift 2
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
  esac
done

cd "$(dirname "$0")"

while read -r post_number; do
  if [[ "$dry_run" == "true" ]]; then
    ./esa-replace.sh $pat $team_name $post_number "$keyword" "$replacement" --dry-run --sleep-sec=$sleep_sec
  else
    ./esa-replace.sh $pat $team_name $post_number "$keyword" "$replacement" --sleep-sec=$sleep_sec
  fi

  # for API invocation limit https://docs.esa.io/posts/102#%E5%88%A9%E7%94%A8%E5%88%B6%E9%99%90
  sleep $sleep_sec
done < <(./esa-findgrep.sh $pat $team_name "$keyword" --sleep-sec=$sleep_sec)
