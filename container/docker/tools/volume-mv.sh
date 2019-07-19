#!/bin/bash

set -x
set -e

OLD=$1; shift
NEW=$1; shift

if [ -z "$OLD" -o -z "$NEW" ]; then
	echo $(basename "$0") OLD NEW
	exit 1
fi

docker volume create --name "$NEW"
docker run --rm -it -v "$OLD":/from -v "$NEW":/to alpine ash -c "cd /from ; cp -av . /to" && docker volume rm "$OLD"
