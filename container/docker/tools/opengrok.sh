#!/bin/bash

set -e

SRC=$1
NAME=${2:-opengrok}
PORT=${3:-3000}

docker run -d --name "$NAME" -v "$SRC":/opengrok/src/$(basename "$SRC") -p $PORT:8080 opengrok/docker:latest
