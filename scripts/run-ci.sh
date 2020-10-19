#!/bin/bash

function update_config {

    sudo rm -R cicd-demo-config

    git clone https://github.com/zeroFruit/cicd-demo-config
    cd cicd-demo-config/config

    kubectl patch --local -f demo-app.yaml -p "{\
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
    }" -o yaml > demo-app-updated.yaml;
    rm demo-app.yaml;
    mv demo-app-updated.yaml demo-app.yaml

    git add .
    git commit -m "Update demo-app to $IMAGE"
    git push

}


IMAGE="zerofruit/cicd-demo-app:$COMMIT"

docker build -t $IMAGE .
docker push $IMAGE

# update config
update_config