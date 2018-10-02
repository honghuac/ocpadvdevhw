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

#stuff goes here

wget https://raw.githubusercontent.com/wkulhanek/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh

chmod +x setup_nexus3.sh

echo "Running setup_nexus3 script in $GUID-nexus"

./setup_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}' -n $GUID-nexus)

sleep 10s;

rm setup_nexus3.sh*

oc expose dc/nexus3 --port=5000 --name=nexus-registry -n $GUID-nexus

oc create route edge nexus-registry --service=nexus-registry --port=5000 -n $GUID-nexus

oc annotate route nexus3 console.alpha.openshift.io/overview-app-route=true

oc annotate route nexus-registry console.alpha.openshift.io/overview-app-route=false

echo "Completed setting up Nexus in project $GUID-nexus"
