#!/bin/bash


echo "Starting to install kubectl"

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "kubectl installed successfully"

echo "creating directory and copy config"
mkdir -p $HOME/.kube
cp k8s-config/config $HOME/.kube/config

if [ "$Status" = "Plan" ]
    then
        echo "Entering Planning Stage"
        kubectl apply -f yaml_files --server-dry-run       
        echo "Leavin Planning Stage"

elif [ "$Status" = "Apply" ]
    then
        echo "Entering Apply Stage"
        kubectl apply -f yaml_files
        echo "Leavin Apply Stage"
fi



