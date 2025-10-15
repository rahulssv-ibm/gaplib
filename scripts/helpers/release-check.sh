#!/bin/bash
# https://gist.githubusercontent.com/electrickite/ba7e734752ee90f04587a24eb6d58b04/raw/9ee75217d17d9c6a2b04bb260d933afebd4b0afb/release-check.sh

usage () {
  cat <<EOF
Usage: release-check.sh [OPTION]... PROJECT...
Check for new releases on Github PROJECTs

Options:
  -h          Print this help text
  -l VERSION  last release version
              Default: last_release
EOF
}

while getopts ":h:l:" opt; do
  case $opt in
    h)
      usage
      exit 0
      ;;
    l)
      last_release_version="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ -z "$1" ]; then
  echo "No projects specified!" >&2
  usage >&2
  exit 1
fi

for project
do
  url="https://api.github.com/repos/$project/releases/latest"
  feed="$(curl -L --silent --fail "$url")"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    echo "Error fetching feed!" >&2
    continue
  fi

  latest_release="$(echo "$feed" | jq .name | tr -d \")"
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    echo "Error parsing feed!" >&2
    continue
  fi

  if [ "$latest_release" != "$last_release_version" ]; then
    echo "New release found for $project"
    echo "New release: $latest_release"
    echo "$latest_release" > /tmp/new_version
    echo "Previous release: $last_release_version"

    export BUILD_IMAGE=true

    # if [ -n "$last_release" ]; then
    #   sed -i '' "s|$project     .*|$project     $latest_release|" "$last_release_path"
    # else
    #   printf '%s\t%s\n' "$project" "$latest_release" >> "$last_release_path"
    # fi

    # if [ -n "$to" ]; then
    #   from_arg=""
    #   if [ -n "$from" ]; then
    #     from_arg="-r $from"
    #   fi
    # fi
  else
    echo "No new releases for $project"
    echo "Current release: $last_release_version"
    exit 1
    # shellcheck disable=SC2317
    export BUILD_IMAGE=false
  fi
done
