#!/usr/bin/env bash

# Search all posts by exactly keyword
#
# USage:
#   ./esa-findgrep.sh <personal access token> <team name> <exactly keyword> [--print-url] [--sleep-sec=<sleep second>]

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
  echo 'Please give exactly keyword' >&2
  exit 1
else
  exactly_keyword=$3
fi

shift 3

print_url=false
sleep_sec=25
while [[ $# -gt 0 ]]; do
  case $1 in
    --print-url)
        print_url=true
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

if [[ "$print_url" == "true" ]]; then
  jq --arg q "$exactly_keyword" -nr '@uri "https://'$team_name'.esa.io/posts?q=\($q)"'
else
  for index in `seq 1 1000`; do
    # https://docs.esa.io/posts/102#GET%20/v1/teams/:team_name/posts
    result=$(curl \
      --fail \
      --get \
      --silent \
      "https://api.esa.io/v1/teams/$team_name/posts" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $pat" \
      --data-urlencode "q=$exactly_keyword" \
      --data-urlencode 'sort=created' \
      --data-urlencode 'per_page=100' \
      --data-urlencode "page=$index")
    echo "$result" | jq -c '.posts[].number'
    echo "$result" | jq --exit-status '.next_page == null' > /dev/null && break

    # for API invocation limit https://docs.esa.io/posts/102#%E5%88%A9%E7%94%A8%E5%88%B6%E9%99%90
    sleep $sleep_sec
  done
fi
