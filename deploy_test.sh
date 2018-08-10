#!/bin/bash
#set -x

# Make sure the cluster is running and get the ip_address
ip_addr=$(bx cs workers $PIPELINE_KUBERNETES_CLUSTER_NAME | grep normal | awk '{ print $2 }')
if [ -z $ip_addr ]; then
  echo "$PIPELINE_KUBERNETES_CLUSTER_NAME not created or workers not ready"
  exit 1
fi

# Initialize script variables
echo 'try to get port from image - else use 5000'
NAME="bookapi"
IMAGE="registry.eu-de.bluemix.net/ethilesen/bookapi:latest"
PORT=$(bx cr image-inspect $IMAGE --format "{{ .ContainerConfig.ExposedPorts }}" | sed -E 's/^[^0-9]*([0-9]+).*$/\1/')
if [ -z "$PORT" ]; then
    PORT=5000
    echo "Port not found in Dockerfile, using $PORT"
fi

echo ""
echo "Deploy environment variables:"
echo "NAME=$NAME"
echo "IMAGE=$IMAGE"
echo "PORT=$PORT"
echo ""

echo 'check if book-api are running - if so perform rolling update...'
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
  kubectl set image deployments/$NAME app=$IMAGE
fi
echo ""
echo "DEPLOYED SERVICE:"
kubectl describe services $NAME
echo ""
echo "DEPLOYED PODS:"
kubectl describe pods --selector app=$NAME
echo ""

# Show the IP address and the PORT of the running app
port=$(kubectl get services | grep "$NAME " | sed 's/.*:\([0-9]*\).*/\1/g')
echo "RUNNING APPLICATION:"
echo "URL=http://$ip_addr"
echo "PORT=$port"
echo ""
echo "$NAME running at: http://$ip_addr:$port"

echo "running final configure of app..."

POD=$(kubectl get pods --selector=app==bookapi -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | tail -n 1)

if [ -z "$POD" ]; then
    echo "No pod available to run migrations."
    exit 1;
else
    kubectl exec -ti $POD npm run knex migrate:latest
fi

echo "done..."
