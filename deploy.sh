#!/bin/bash

echo "Create Guestbook"
IP_ADDR=$(bx cs workers $CLUSTER_NAME | grep normal | awk '{ print $2 }')
if [ -z $IP_ADDR ]; then
  echo "$CLUSTER_NAME not created or workers not ready"
  exit 1
fi

echo -e "Configuring vars"
exp=$(bx cs cluster-config $CLUSTER_NAME | grep export)
if [ $? -ne 0 ]; then
  echo "Cluster $CLUSTER_NAME not created or not ready."
  exit 1
fi
eval "$exp"



echo -e "Creating pods"
kubectl create -f ./deploy

PORT=$(kubectl get services | grep frontend | sed 's/.*:\([0-9]*\).*/\1/g')

echo ""
echo "View the guestbook at http://$IP_ADDR:$PORT"
