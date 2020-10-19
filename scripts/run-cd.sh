#!/bin/bash


function update_manifest {

    git clone https://github.com/zeroFruit/cicd-demo-manifest
    cd cicd-demo-manifest/manifest

    cp $DEST config.yaml

    git add .
    git commit -m "Update demo-app manifest [ID]"
    git push

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


# update configmap
for FILE in $(git diff --name-only HEAD HEAD~1); do

    # if filename contains application.yaml execute
    if grep -q "application.yaml" <<< $FILE; then
        make_configmap
        update_manifest
    fi
done
