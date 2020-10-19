#!/bin/bash

# 커밋 해시를 첫 번째 인자로 받음
COMMIT=$1

REPO_URL="https://github.com/zeroFruit/cicd-demo-manifest"
ROOT=$PWD

#####
# ConfigMap 업데이트
#####

DIFF_FILES=$(git diff --name-only HEAD HEAD~1)

echo $DIFF_FILES
git clone $REPO_URL
cd cicd-demo-manifest/manifest/demo-app

# list filenames contained in `git diff`
for FILE in $DIFF_FILES; do

    # if filename contains application.yaml execute
    if grep -q "application.yaml" <<< "$ROOT/$FILE"; then

        # ConfigMap 생성 로직
        DEST="$ROOT/$(dirname $FILE)/config.yaml"
        echo "Dest: $DEST"

        echo "apiVersion: v1
kind: ConfigMap
metadata:
  name: game-demo
data:
  application.yaml: |" > $DEST

        # Print application.yaml file. Each line start with 4 whitespaces
        cat $ROOT/$FILE | awk '{print "    " $0}' >> $DEST


        # 생성한 ConfigMap을 클론한 디렉토리로 복사
        cp $DEST config.yaml

        git add .

        # 생성한 ConfigMap로 패치 후 변경사항 커밋
        git commit -m "Update demo-app manifest $FILE"
    fi
done

cd $ROOT



#####
# Deployment 업데이트
#####
IMAGE="zerofruit/cicd-demo-app:$COMMIT"

# Docker 빌드
docker build -t $IMAGE .
docker push $IMAGE

# deployment.yaml의 이미지 태그 바꿔치기
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
mv deployment-updated.yaml deployment.yaml

git add .

# 생성한 Deployment로 패치 후 변경사항 커밋
git commit -m "Update demo-app to $IMAGE"
# git push