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
sleep 5s;
oc expose svc nexus3
sleep 5s;
oc rollout pause dc nexus3
sleep 5s;
oc patch dc nexus3 --patch='{ "spec": { "strategy": { "type": "Recreate" }}}'
oc set resources dc nexus3 --limits=memory=2Gi --requests=memory=1Gi
echo "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nexus-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi" | oc create -f -
sleep 5s;
oc set volume dc/nexus3 --add --overwrite --name=nexus3-volume-1 --mount-path=/nexus-data/ --type persistentVolumeClaim --claim-name=nexus-pvc
oc set probe dc/nexus3 --liveness --failure-threshold 3 --initial-delay-seconds 60 -- echo ok
oc set probe dc/nexus3 --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:8081/repository/maven-public/
oc rollout resume dc nexus3
sleep 5s;
curl -o setup_nexus3.sh -s https://raw.githubusercontent.com/wkulhanek/ocp_advanced_development_resources/master/nexus/setup_nexus3.sh
chmod +x setup_nexus3.sh
./setup_nexus3.sh admin admin123 http://$(oc get route nexus3 --template='{{ .spec.host }}')
rm setup_nexus3.sh
oc expose dc nexus3 --port=5000 --name=nexus-registry
sleep 5s;
oc create route edge nexus-registry --service=nexus-registry --port=5000
