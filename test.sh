#!/bin/bash

STATUS=""
if [ $STATUS!=$(kubectl get pods --selector=app==bookapi -o go-template --template '{{range .items}}{{.status.phase}}{{"\n"}}{{end}}' | grep Running)  ]; then
  echo 'done.'
else
  echo 'not running'
fi
