#!/bin/sh

ACCOUNT_ID="347786937011"
REGION="us-west-2"
PREFIX=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
SRC_LOCAL_IMG_TAG="runtime"
AWS_TARGET_IMG_TAG="runtime_spdemo"

# Check if the environment variable is set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "AWS CLI Environment variables not set. Exiting."
    exit 1
fi

aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${PREFIX}

# benchmark
docker tag applications.services.devcloud.workbench-benchmark:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-benchmark:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-benchmark:${AWS_TARGET_IMG_TAG}

# sso
docker tag applications.services.devcloud.workbench-sso:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-sso:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-sso:${AWS_TARGET_IMG_TAG}

# client
docker tag applications.services.devcloud.workbench-client:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-client:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-client:${AWS_TARGET_IMG_TAG}

# bus
docker tag applications.services.devcloud.workbench-bus:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-bus:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-bus:${AWS_TARGET_IMG_TAG}

# project
docker tag applications.services.devcloud.workbench-project:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-project:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-project:${AWS_TARGET_IMG_TAG}

# omz
docker tag applications.services.devcloud.workbench-omz:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-omz:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-omz:${AWS_TARGET_IMG_TAG}

# fs
docker tag applications.services.devcloud.workbench-fs:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-fs:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-fs:${AWS_TARGET_IMG_TAG}

# optimize
docker tag applications.services.devcloud.workbench-optimize:${SRC_LOCAL_IMG_TAG} ${PREFIX}/applications.services.devcloud.workbench-optimize:${AWS_TARGET_IMG_TAG}
docker push ${PREFIX}/applications.services.devcloud.workbench-optimize:${AWS_TARGET_IMG_TAG}