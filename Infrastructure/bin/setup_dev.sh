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

# Add similar command -- oc new-app docker.io/rocketchat/rocket.chat:0.63.3 -e MONGO_URL="mongodb://mongodb_user:mongodb_password@mongodb:27017/mongodb?replicaSet=rs0"

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Development Environment in project ${GUID}-parks-dev"

oc project ${GUID}-parks-dev

#Create MongoDB headless service

oc create -f "./Infrastructure/templates/setup_dev/mongohlsvc.yaml" -n ${GUID}-parks-dev

sleep 5s;

#Create MongoDB service

oc create -f "./Infrastructure/templates/setup_dev/mongosvc.yaml" -n ${GUID}-parks-dev

sleep 5s;

#Create MongoDB stateful set

oc create -f "./Infrastructure/templates/setup_dev/mongosfs.yaml" -n ${GUID}-parks-dev

sleep 5s;

#Add role

oc policy add-role-to-user view --serviceaccount=default -n ${GUID}-parks-dev

#Build ParksMap app

oc new-build --binary=true --name="parksmap-binary" --image-stream=redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
sleep 5s;

oc start-build parksmap-binary --from-file=./ParksMap/target/parksmap.jar --follow -n ${GUID}-parks-dev
sleep 5s;

oc new-app ${GUID}-parks-dev/parksmap:0.0-0 --name=parksmap --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
sleep 5s;

oc expose svc parksmap --port 8080 --labels='type=parksmap-backend'

oc delete configmap parksmap-config -n ${GUID}-parks-dev --ignore-not-found=true
oc create configmap parksmap-config --from-file=./Infrastructure/templates/setup_dev/parksmap.properties -n ${GUID}-parks-dev

#oc create configmap parksmap-config --from-literal="parksmap.properties=Placeholder" -n ${GUID}-parks-dev
oc set volume dc/parksmap --add --name=parksmap-config --mount-path=./Infrastructure/templates/setup_dev/parksmap.properties --configmap-name=parksmap-config -n ${GUID}-parks-dev
#are tags needed for dc?
sleep 5s;

oc set probe dc/parksmap --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok -n ${GUID}-parks-dev
oc set probe dc/parksmap --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:8080/ws/appname/ -n ${GUID}-parks-dev


#Test ParksMap app

#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/parksmap -o template --template {{.spec.host}})"/ws/backends/list/"`
#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/parksmap -o template --template {{.spec.host}})"/ws/appname/"`


#Build MLBParks app

oc new-build --binary=true --name="mlbparks-binary" --image-stream=jboss-eap70-openshift:1.7 -n ${GUID}-parks-dev
sleep 5s;

pwd
ls

oc start-build mlbparks-binary --from-file=./MLBParks/target/mlbparks.war --follow -n ${GUID}-parks-dev
sleep 5s;

oc new-app ${GUID}-parks-dev/mlbparks:0.0-0 --name=mlbparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
sleep 5s;

oc expose svc mlbparks --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-dev

oc delete configmap mlbparks-config -n ${GUID}-parks-dev --ignore-not-found=true
oc create configmap mlbparks-config --from-file=./Infrastructure/templates/setup_dev/mlbparks.properties -n ${GUID}-parks-dev

#oc create configmap mlbparks-config --from-literal="mlbparks.properties=Placeholder" -n ${GUID}-parks-dev
oc set volume dc/mlbparks --add --name=mlbparks-config --mount-path=./Infrastructure/templates/setup_dev/mlbparks.properties --configmap-name=mlbparks-config -n ${GUID}-parks-dev
#are tags needed for dc?
sleep 5s;

oc set probe dc/mlbparks --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok -n ${GUID}-parks-dev
oc set probe dc/mlbparks --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:8080/ws/healthz/ -n ${GUID}-parks-dev


#Test MLBParks app

#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/mlbparks -o template --template {{.spec.host}})"/ws/healthz/"`
#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/mlbparks -o template --template {{.spec.host}})"/ws/data/load/"`
#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/mlbparks -o template --template {{.spec.host}})"/ws/info/"`


#Build NationalParks app
oc new-build --binary=true --name="nationalparks" --image-stream=redhat-openjdk18-openshift:1.2 -n ${GUID}-parks-dev
sleep 5s;

oc start-build nationalparks-binary --from-file=./NationalParks/target/nationalparks.jar --follow -n ${GUID}-parks-dev
sleep 5s;

oc new-app ${GUID}-parks-dev/nationalparks:0.0-0 --name=nationalparks --allow-missing-imagestream-tags=true -n ${GUID}-parks-dev
sleep 5s;

oc expose svc nationalparks --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-dev

oc delete configmap nationalparks-config -n ${GUID}-parks-dev --ignore-not-found=true
oc create configmap nationalparks-config --from-file=./Infrastructure/templates/setup_dev/nationalparks.properties -n ${GUID}-parks-dev

#oc create configmap nationalparks-config --from-literal="nationalparks.properties=Placeholder"
oc set volume dc/nationalparks --add --name=nationalparks-config --mount-path=./Infrastructure/templates/setup_dev/nationalparks.properties --configmap-name=nationalparks-config -n ${GUID}-parks-dev
#are tags needed for dc?

oc set probe dc/nationalparks --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok -n ${GUID}-parks-dev
oc set probe dc/nationalparks --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:8080/ws/healthz/ -n ${GUID}-parks-dev

sleep 5s;

#Test NationalParks app

#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/nationalparks -o template --template {{.spec.host}})"/ws/healthz/"`
#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/nationalparks -o template --template {{.spec.host}})"/ws/data/load/"`
#curl -i -v -k `echo "https://"$(oc get route/${GUID}-parks-dev/nationalparks -o template --template {{.spec.host}})"/ws/info/"`
