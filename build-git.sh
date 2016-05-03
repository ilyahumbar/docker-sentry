#!/bin/bash
set -e

usage () {
    echo "usage: $0 <sha>"
    exit 1
}

if [ "$#" = 0 ]; then
    set -- "$(curl -sSL 'https://api.github.com/repos/buildinglink/sentry/git/refs/heads/blk-changes' | awk -F '"' '$2 == "sha" { print $4 }')"
    echo "No sha specified, using refs/head/blk-changes ($1)"
fi

[[ "$#" = 1 ]] || usage

sha="$1"
[[ $sha =~ ^[a-f0-9]{40}$ ]] || usage

set -x
docker build --build-arg SENTRY_BUILD=$sha --rm -t ilyahumbar/sentry git
