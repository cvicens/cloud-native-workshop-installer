#!/bin/sh

TOKEN=$(oc whoami -t | base64)

NAMESPACE="ccn-installer"

if [ -z "${TOKEN}" ]
then
    echo "You have to log in in your OCP cluster ;-)"
    exit 1
fi

oc new-project ${NAMESPACE}

oc delete secret ccn-token-secret -n ${NAMESPACE}

cat ./ccn-token-secret.yaml | \
  sed "s/{{\b*NAMESPACE\b*}}/$(echo -n ${NAMESPACE} | base64)/" | \
  sed "s/{{\b*TOKEN\b*}}/${TOKEN}/" | oc create -n ${NAMESPACE} -f -

oc delete job ccn-uninstaller-batch -n ${NAMESPACE} ;  oc apply -n ${NAMESPACE} -f ./ccn-uninstaller-batch.yaml