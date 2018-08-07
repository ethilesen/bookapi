#!/bin/bash
NAME="bookapi"
IMAGE="registry.eu-de.bluemix.net/ethilesen/bookapi"
PORT=$(bx cr image-inspect $IMAGE --format "{{ .ContainerConfig.ExposedPorts }}" | sed -E 's/^[^0-9]*([0-9]+).*$/\1/')
if [ -z "$PORT" ]; then
    PORT=5000
    echo "Port not found in Dockerfile, using $PORT"
fi

