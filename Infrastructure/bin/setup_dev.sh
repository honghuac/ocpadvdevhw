#!/bin/bash
# Setup Development Project
#Grant the correct permissions to the Jenkins service account
#Create a MongoDB database
#Create binary build configurations for the pipelines to use for each microservice
#Create ConfigMaps for configuration of the applications
#    Set APPNAME to the following values—the grading pipeline checks for these exact strings:
#        MLB Parks (Dev)
#        National Parks (Dev)
#        ParksMap (Dev)
#Set up placeholder deployment configurations for the three microservices
#Configure the deployment configurations using the ConfigMaps
#Set deployment hooks to populate the database for the back end services
#Set up liveness and readiness probes
#Expose and label the services properly (parksmap-backend)

#Metadata name of VolumeClaimTemplates and name of volumeMount must be the same. The pair in dev must be distinct from the pair in prod.


if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

oc project ${GUID}-parks-dev

#Create MongoDB headless service

oc create -f ../templates/setup_dev/mongohlsvc.yaml

sleep 5s;

#Create MongoDB service

oc create -f ../templates/setup_dev/mongosvc.yaml

sleep 5s;

#Create MongoDB stateful set

oc create -f ../templates/setup_dev/mongosfs.yaml

sleep 5s;

oc new-build --binary=true --name="mlbparks" jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev

sleep 5s;

oc new-app ${GUID}-parks-dev/mlbparks:0.0-0 --name=mlbparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev

sleep 5s;

oc expose dc mlbparks --port 8080 -n ${GUID}-parks-dev

sleep 5s;

oc expose svc mlbparks -n ${GUID}-parks-dev

sleep 5s;

oc new-build --binary=true --name="nationalparks" redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev

sleep 5s;

oc new-app ${GUID}-parks-dev/nationalparks:0.0-0 --name=nationalparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev

sleep 5s;

oc expose dc nationalparks --port 8080 -n ${GUID}-parks-dev

sleep 5s;

oc expose svc nationalparks -n ${GUID}-parks-dev

sleep 5s;

oc new-build --binary=true --name="parksmap" redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev

sleep 5s;

oc new-app ${GUID}-parks-dev/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev

sleep 5s;

oc expose dc parksmap --port 8080 -n ${GUID}-parks-dev

sleep 5s;

oc expose svc parksmap -n ${GUID}-parks-dev
