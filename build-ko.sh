#!/bin/bash
set -e

usage() { 
    echo "Usage: "
    echo "$0 [-t <tag>]
             [-h]" 1>&2; 
    echo "-t : Give a tag to the image. Build for minikube if not provided."
    echo "-h : Display help" 
    echo ""
    exit 0; 
}

microservice=service-mesh
user=docker #pass=tcuser
baseImageTag=v0.1.3
imageTag=ZOLARA_GIT_TAG

while getopts "t:h" option; do
    options+="$option"
    case "${option}" in
        t)
            if [[ $2 = \v* ]]; then
                imageTag=$2
            else
                echo "The tag ${OPTARG} has an invalid format. It has to starts with the letter 'v'"
                exit 1
            fi
            ;;
        h)
            usage
            ;;
        \? )
            usage
            ;;
    esac
done

echo "$microservice build started"
docker pull gcr.io/distroless/static-debian12
docker run --privileged --rm -v $(pwd):/workspace/zolara/$microservice -v "/var/run/docker.sock:/var/run/docker.sock:rw" -w /workspace/$microservice gcr.io/distroless/static-debian12 build --local -t $imageTag --base-import-paths