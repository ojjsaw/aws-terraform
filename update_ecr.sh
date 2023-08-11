#!/bin/sh

ACCOUNT_ID="868686364197"
REGION="us-west-2"
PREFIX=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Check if the environment variable is set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "AWS CLI Environment variables not set. Exiting."
    exit 1
fi

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${PREFIX}

# benchmark
docker tag applications.services.devcloud.workbench-benchmark:runtime ${PREFIX}/applications.services.devcloud.workbench-benchmark:runtime
docker push ${PREFIX}/applications.services.devcloud.workbench-benchmark:runtime

# sso
docker tag applications.services.devcloud.workbench-sso:runtime ${PREFIX}/applications.services.devcloud.workbench-sso:runtime
docker push ${PREFIX}/applications.services.devcloud.workbench-sso:runtime

# client
docker tag applications.services.devcloud.workbench-client:runtime ${PREFIX}/applications.services.devcloud.workbench-client:runtime
docker push ${PREFIX}/applications.services.devcloud.workbench-client:runtime

# bus
docker tag applications.services.devcloud.workbench-bus:runtime ${PREFIX}/applications.services.devcloud.workbench-bus:runtime
docker push ${PREFIX}/applications.services.devcloud.workbench-bus:runtime

# project
docker tag applications.services.devcloud.workbench-project:runtime ${PREFIX}/applications.services.devcloud.workbench-project:runtime
docker push ${PREFIX}/applications.services.devcloud.workbench-project:runtime

# omz
docker tag applications.services.devcloud.workbench-omz:runtime ${PREFIX}/applications.services.devcloud.workbench-omz:runtime
docker push ${PREFIX}/applications.services.devcloud.workbench-omz:runtime