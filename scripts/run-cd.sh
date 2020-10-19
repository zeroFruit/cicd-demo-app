#!/bin/bash

# 커밋 해시를 첫 번째 인자로 받음
COMMIT=$1

REPO_URL="https://github.com/zeroFruit/cicd-demo-manifest"
ROOT=$PWD

#####
# ConfigMap 업데이트
#####

function update_manifest {

    git clone $REPO_URL
    cd cicd-demo-manifest/manifest/demo-app

    cp "$ROOT/$DEST" config.yaml

    git add .

    # 생성한 ConfigMap로 패치 후 변경사항 커밋
    git commit -m "Update demo-app manifest $FILE"

}

function make_configmap {
    DEST="$(dirname $FILE)/config.yaml"

    echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  application.yaml: |" > $DEST

    # Print application.yaml file. Each line start with 4 whitespaces
    cat $FILE | awk '{print "    " $0}' >> $DEST
}

# list filenames contained in `git diff`
for FILE in $(git diff --name-only HEAD HEAD~1); do

    # if filename contains application.yaml execute
    if grep -q "application.yaml" <<< $FILE; then
        make_configmap
        update_manifest
    fi
done

cd $ROOT



#####
# Deployment 업데이트
#####

function update_config {

    cd cicd-demo-manifest/manifest/demo-app

    kubectl patch --local -f deployment.yaml -p "{\
        \"spec\":{\
            \"template\":{\
                \"spec\":{\
                    \"containers\":[{\
                        \"name\":\"demo-app\",\
                        \"image\":\"$IMAGE\"\
                    }]\
                }\
            }\
        }\
    }" -o yaml > deployment-updated.yaml;
    rm deployment.yaml;
    mv deployment-updated.yaml demo-app.yaml

    git add .

    # 생성한 Deployment로 패치 후 변경사항 커밋
    git commit -m "Update demo-app to $IMAGE"
    git push

}


IMAGE="zerofruit/cicd-demo-app:$COMMIT"

docker build -t $IMAGE .
docker push $IMAGE

# update config
update_config