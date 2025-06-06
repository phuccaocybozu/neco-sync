#!/bin/bash
#
# Script to sync files to a Kubernetes pod using Teleport and kubectl

. src/config/config.sh

unset_proxies() {
    unset HTTPS_PROXY HTTP_PROXY https_proxy http_proxy
}

login_teleport() {
    echo "-------------------------------------------------------"
    echo "Login to Teleport proxy at $PROXY"
    tsh login --proxy=$PROXY $HOST
}

login_kube() {
    echo "-------------------------------------------------------"
    echo "Login to $HOST"
    tsh kube login $HOST
}

list_pods() {
    echo "-------------------------------------------------------"
    echo "Find the name of the pod you want to access"
    kubectl get pods -n $NAME_SPACE | grep $RELEASE_CHANNEL
}

select_pod() {
    echo "-------------------------------------------------------"
    echo "Choose the pod you want to access:"
    read -p "Pod name: " POD
    while [ -z "$POD" ]; do
        echo "Pod name cannot be empty. Please enter a valid pod name."
        read -p "Pod name: " POD
    done
}

check_pod_exists() {
    echo "-------------------------------------------------------"
    echo "Checking pod $POD"
    kubectl get pod $POD -n $NAME_SPACE
    if [ $? -ne 0 ]; then
        echo "Pod $POD not found in namespace $NAME_SPACE."
        exit 1
    fi
}

sync_files() {
    echo "-------------------------------------------------------"
    echo "Syncing files to pod $POD in namespace $NAME_SPACE"
    kubectl cp -n $NAME_SPACE -c garoon-ap $LOCAL_REPOSITORY/source/$FOLDER_FILES_TO_SYNC $POD:/usr/local/garoon/$FOLDER_FILES_TO_SYNC
}

exec_pod() {
    echo "-------------------------------------------------------"
    echo "Executing command in pod $POD"
    kubectl exec -it -n $NAME_SPACE -c garoon-ap $POD -- /bin/bash
}

# Main
# run ./src/sync.sh -l to get list pods
if [ "$1" == "-l" ]; then
    unset_proxies
    login_teleport
    login_kube
    list_pods
    exit 0
fi

# run ./src/sync.sh -ex to execute command in pod
if [ "$1" == "-ex" ]; then
    unset_proxies
    login_teleport
    login_kube
    list_pods
    select_pod
    check_pod_exists
    exec_pod
    exit 0
fi

# run ./src/sync.sh -s to sync files to pod
if [ "$1" == "-s" ]; then
    unset_proxies
    login_teleport
    login_kube
    list_pods
    select_pod
    check_pod_exists
    sync_files
    exit 0
fi

# not matching with -l or -s or -ex will show error message
echo "-------------------------------------------------------"
echo "Usage: $0 [-l | -s | -ex]"
echo "  -l   List pods in the namespace"
echo "  -s   Sync files to the selected pod"
echo "  -ex  Execute command in the selected pod"
echo "Please provide a valid option."
exit 1
# End of script