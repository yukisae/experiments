#!/bin/bash

set -e
set -x

VOLUME_PATH=$HOME/notebook

# To set my password into the container, set TOKEN by the output of the following command
# docker run -it --rm jupyter/datascience-notebook python -c 'from notebook.auth import passwd; print(passwd());'
# For example:
# TOKEN=sha1:c072c39162d9:6e3eae65fbb3a8980efde6f3b549907217f6ea44

PORT=8888
IMAGE=jupyter/datascience-notebook

if [ -z "$(docker image ls -q $IMAGE)" ]; then
	docker pull $IMAGE
fi

if [ -n "$TOKEN" ]; then
	AUTHOPT=(--NotebookApp.password="$TOKEN")
else
	AUTHOPT=( \
		# --NotebookApp.password_required=False \
		--NotebookApp.password='' \
		--NotebookApp.token='' \
	)
fi

mkdir -p "$VOLUME_PATH"
docker run --rm -d \
	-v "$VOLUME_PATH:/home/jovyan" \
	-e NB_UID=$UID \
	-e NB_GID=$(id -g) \
	-p $PORT:8888 \
	--name notebook \
	jupyter/datascience-notebook \
	start-notebook.sh ${AUTHOPT[@]}
