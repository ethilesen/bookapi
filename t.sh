#!/bin/bash
NAME="bookapi"
IMAGE="registry.eu-de.bluemix.net/ethilesen/bookapi"
PORT=$(bx cr image-inspect $IMAGE:3 --format "{{ .ContainerConfig.ExposedPorts }}" | sed -E 's/^[^0-9]*([0-9]+).*$/\1/')
if [ -z "$PORT" ]; then
    PORT=5000
    echo "Port not found in Dockerfile, using $PORT"
fi
ROLLING=$(kubectl get po | grep $NAME)
if [ -z "$ROLLING" ]; then
  echo 'perform fresh deploy...'
  # Execute the file
  echo "KUBERNETES COMMAND:"
  echo "kubectl apply -f ./deploy"
  kubectl apply -f ./deploy
  echo ""
else
  echo 'bookapi exist - performs rolling update!'
  kubectl set image deployments/$NAME app=$IMAGE:latest
fi
