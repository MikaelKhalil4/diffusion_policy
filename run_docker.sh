#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <container_name>"
  exit 1
fi

CONTAINER_NAME=$1

echo "Building image and starting container '$CONTAINER_NAME' as your user..."

export HOST_UID=$(id -u)
export HOST_GID=$(id -g)
export CONTAINER_NAME

docker compose -p "$CONTAINER_NAME" up -d


sleep 2
docker exec -it "$CONTAINER_NAME" bash
