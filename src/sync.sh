#! /bin/bash
#
# Script to sync files to a Kubernetes pod using Teleport and kubectl
. ../config/config.sh

unset HTTPS_PROXY
unset HTTP_PROXY
unset https_proxy
unset http_proxy
echo "-------------------------------------------------------"
echo "Login to Teleport proxy at $PROXY"
tsh login --proxy=$PROXY $HOST

echo "-------------------------------------------------------"
echo "Login to $HOST"
tsh kube login $HOST

echo "-------------------------------------------------------"
echo "Find the name of the pod you want to access"
kubectl get pods -n $NAME_SPACE | grep $RELEASE_CHANNEL

echo "-------------------------------------------------------"
echo "Choose the pod you want to access:"
read -p "Pod name: " POD
while [ -z "$POD" ]; do
    echo "Pod name cannot be empty. Please enter a valid pod name."
    read -p "Pod name: " POD
done

echo "-------------------------------------------------------"
echo "Checking pod $POD"
kubectl get pod $POD -n $NAME_SPACE
if [ $? -ne 0 ]; then
    echo "Pod $POD not found in namespace $NAME_SPACE."
    exit 1
fi

echo "-------------------------------------------------------"
echo "Syncing files to pod $POD in namespace $NAME_SPACE"
kubectl cp -n $NAME_SPACE -c garoon-ap $LOCAL_REPOSITORY/source/$FOLDER_FILES_TO_SYNC $POD:/usr/local/garoon/$FOLDER_FILES_TO_SYNC

