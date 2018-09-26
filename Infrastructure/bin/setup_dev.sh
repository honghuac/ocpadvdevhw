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

oc create -f "../templates/setup_dev/mongohlsvc.yaml"

sleep 5s;

#Create MongoDB service

oc create -f "../templates/setup_dev/mongosvc.yaml"

sleep 5s;

#Create MongoDB stateful set

oc create -f "../templates/setup_dev/mongosfs.yaml"

sleep 5s;

#Add role

oc policy add-role-to-user view --serviceaccount=default

#Build ParksMap app

oc new-build --binary=true --name="parksmap-binary" --image-stream=redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
sleep 5s;

oc start-build parksmap-binary --from-file=$HOME/ocpadvdevhw/ParksMap/target/parksmap.jar --follow -n ${GUID}-parks-dev
sleep 5s;

oc new-app ${GUID}-parks-dev/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
oc expose svc/parksmap-binary --labels='type=parksmap-backend'

oc create configmap parksmap-config --from-literal="parksmap.properties=Placeholder" -n ${GUID}-parks-dev
oc set volume dc/parksmap --add --name=parksmap-config --mount-path=$HOME/parksmap.properties --configmap-name=parksmap-config -n ${GUID}-parks-dev
#are tags needed for dc?
sleep 5s;

#Test ParksMap app

curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/parksmap -o template --template {{.spec.host}})"/ws/backends/list/"`
curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/parksmap -o template --template {{.spec.host}})"/ws/appname/"`


#Build MLBParks app

oc new-build --binary=true --name="mlbparks-binary" --image-stream=jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev
sleep 5s;

oc start-build parksmap-binary --from-file=$HOME/ocpadvdevhw/MLBParks/target/mlbparks.jar --follow -n ${GUID}-parks-dev
sleep 5s;

oc new-app ${GUID}-parks-dev/mlbparks:0.0-0 --name=mlbparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
sleep 5s;

#oc expose dc mlbparks --port 8080 -n ${GUID}-parks-dev ??

oc expose svc mlbparks -n ${GUID}-parks-dev
oc create configmap mlbparks-config --from-literal="mlbparks.properties=Placeholder" -n ${GUID}-parks-dev
oc set volume dc/mlbparks --add --name=mlbparks-config --mount-path=$HOME/mlbparks.properties --configmap-name=mlbparks-config -n ${GUID}-parks-dev
#are tags needed for dc?
sleep 5s;

#Test MLBParks app

curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/mlbparks -o template --template {{.spec.host}})"/ws/healthz/"`
curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/mlbparks -o template --template {{.spec.host}})"/ws/data/load/"`
curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/mlbparks -o template --template {{.spec.host}})"/ws/info/"`


#Build NationalParks app
oc new-build --binary=true --name="nationalparks" --image-stream=redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
sleep 5s;

oc start-build nationalparks-binary --from-file=$HOME/ocpadvdevhw/NationalParks/target/nationalparks.jar --follow -n ${GUID}-parks-dev
sleep 5s;

oc new-app ${GUID}-parks-dev/nationalparks:0.0-0 --name=nationalparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
sleep 5s;

#oc expose dc nationalparks --port 8080 -n ${GUID}-parks-dev ??

oc expose svc nationalparks -n ${GUID}-parks-dev
oc create configmap nationalparks-config --from-literal="nationalparks.properties=Placeholder"
oc set volume dc/nationalparks --add --name=nationalparks-config --mount-path=$HOME/nationalparks.properties --configmap-name=nationalparks-config -n ${GUID}-parks-dev
#are tags needed for dc?
sleep 5s;

#Test NationalParks app

curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/nationalparks -o template --template {{.spec.host}})"/ws/healthz/"`
curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/nationalparks -o template --template {{.spec.host}})"/ws/data/load/"`
curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/nationalparks -o template --template {{.spec.host}})"/ws/info/"`
