#!/usr/bin/env bash

# Replace keyword on esa.io post body.
#
# USage:
#   ./esa-replace.sh <personal access token> <team name> <post number> <keyword> <replacement> [--dry-run] [-n]

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
  echo 'Please give post number.' >&2
  exit 1
else
  post_number=$3
fi

if [ -z ${4+x} ]; then
  echo 'Please give keyword' >&2
  exit 1
else
  keyword=$4
fi

if [ -z ${5+x} ]; then
  echo 'Please give replacement' >&2
  exit 1
else
  replacement=$5
fi

shift 5

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

# https://docs.esa.io/posts/102#GET%20/v1/teams/:team_name/posts/:post_number
post=$(curl \
  -f \
  --get \
  --silent \
  "https://api.esa.io/v1/teams/$team_name/posts/$post_number" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $pat")

body_md=$(echo $post | jq '.body_md')
new_body_md=${body_md//$keyword/$replacement} # replace strings

# https://docs.esa.io/posts/102#PATCH%20/v1/teams/:team_name/posts/:post_number
patch_request_body=$(echo $post | jq --argjson new_body_md "$new_body_md" -c '
{
  "post": {
    "name": .name,
    "body_md": $new_body_md,
    "tags": .tags,
    "category": .category,
    "wip": .wip,
    "message": "Updated by esa-sed.sh",
    "original_revision": {
        "body_md": .body_md,
        "number": .revision_number,
        "user": .updated_by.screen_name
      }
  }
}
')

if [[ "$dry_run" == "true" ]]; then
  echo $patch_request_body
else
  curl \
    -f \
    -i \
    -X PATCH \
    --silent \
    "https://api.esa.io/v1/teams/$team_name/posts/$post_number" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $pat" \
    --data "$patch_request_body"
fi
