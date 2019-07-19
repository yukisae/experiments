#!/bin/bash

docker ps --all --format '{{.ID}}' | xargs docker rm
