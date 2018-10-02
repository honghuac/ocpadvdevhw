#!/bin/bash
# Setup Nexus Project
#Create a new Nexus instance from docker.io/sonatype/nexus3:latest
#Configure Nexus appropriately for resources, deployment strategy, persistent volumes, and readiness and liveness probes
#When Nexus is running, populate Nexus with the correct repositories
#Expose the container registry


if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Nexus in project $GUID-nexus"

oc new-app sonatype/nexus3:latest -n $GUID-nexus

sleep 15s;

oc expose svc/nexus3 -n $GUID-nexus

sleep 5s;

oc rollout pause dc/nexus3 -n $GUID-nexus

sleep 5s;

oc patch dc/nexus3 --patch='{ "spec": { "strategy": { "type": "Recreate" }}}' -n $GUID-nexus

oc set resources dc/nexus3 --limits=memory=2Gi --requests=memory=1Gi -n $GUID-nexus

oc create -f "./Infrastructure/templates/setup_nexus/nexus.yaml" -n $GUID-nexus

sleep 5s;

echo "Setting PV and probes in project $GUID-nexus"

oc set volume dc/nexus3 --add --overwrite --name=nexus3-volume-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc -n $GUID-nexus

oc set probe dc/nexus3 --liveness --failure-threshold 3 --initial-delay-seconds 60 -n $GUID-nexus -- echo ok

oc set probe dc/nexus3 --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/repository/maven-public/ -n $GUID-nexus

oc rollout resume dc nexus3 -n $GUID-nexus

sleep 5m;

#stuff goes here

echo "Completed setting up Nexus in project $GUID-nexus"
