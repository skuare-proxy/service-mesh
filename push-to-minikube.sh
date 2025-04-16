#!/bin/bash
set -e

microservice=service-mesh
namespace=default
user=docker
host=$(minikube ip -p zolara)
image=nexuszolara.me/skuare-proxy/$microservice

echo "Push to minikube Started"
GOOS=linux GARCH=amd64 CGO_ENABLED=0 go build -o app
chmod +x app
docker build . -t $image:SKUARE_GIT_TAG -f Dockerfile
docker save -o image.tar $image:SKUARE_GIT_TAG

# sshpass -p "tcuser" scp image.tar $user@$host:/tmp/image.tar
# sshpass -p "tcuser" ssh -t $user@$host "docker load -i /tmp/image.tar"

minikube -p zolara cp image.tar /tmp/image.tar
minikube -p zolara ssh "docker load -i /tmp/image.tar"

rm image.tar
rm app

sed -i 's/version: SKUARE_GIT_TAG/version: v0-SKUARE_GIT_TAG/' helm/$microservice/Chart.yaml
helm upgrade --install zolara-$microservice -n $namespace helm/$microservice --reset-values
sed -i 's/version: v0-SKUARE_GIT_TAG/version: SKUARE_GIT_TAG/' helm/$microservice/Chart.yaml

kubectl delete pods -n $namespace -l app=$microservice