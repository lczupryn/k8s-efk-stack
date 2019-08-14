#!/bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 [release-name] [namespace(optional)]"
    printf "\t %s \t\t %s \n\t\t\t\t %s \n" "Define Relase-name for EFK helm chart and K8s namespace where chart should be applied -default logging"
    exit 1
fi
if [ $# -lt 2 ]; then
    export NAMESPACE=logging
else
    export NAMESPACE=$2
fi
export RELEASE_NAME=$1
export URL_EXPOSED=kibana.$RELEASE_NAME.$(kubectl get services -l component=controller,app=nginx-ingress --all-namespaces -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}").nip.io

echo "RELEASE_NAME=$RELEASE_NAME"
echo "NAMESPACE=$NAMESPACE"
echo "URL_EXPOSED=$URL_EXPOSED"
#Replace RELEASE_NAME_TO_CHANGE
sed -i -e "s/RELEASE_NAME_TO_CHANGE/$RELEASE_NAME/" values.yaml

#helm update dependecies
helm dep update
#install helm chart
helm install --name $RELEASE_NAME . --set ingress.hosts.host=$URL_EXPOSED --namespace $NAMESPACE
