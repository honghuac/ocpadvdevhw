#!/bin/bash
# Setup Production Project (initial active services: Green)

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Student


#    Grant the correct permissions to the Jenkins service account
#    Grant the correct permissions to pull images from the development project
#    Grant the correct permissions for the ParksMap application to read back-end services (see the associated README file)
#    Set up a replicated MongoDB database via StatefulSet with at least three replicas
#    Set up blue and green instances for each of the three microservices
#    Use ConfigMaps to configure them
#        Set APPNAME to the following values—the grading pipeline checks for these exact strings:
#            MLB Parks (Green)
#            MLB Parks (Blue)
#            National Parks (Green)
#            National Parks (Blue)
#            ParksMap (Green)
#            ParksMap (Blue)

# Make the Green service active initially to guarantee a Blue rollout upon the first pipeline run

# Add similar commands -- oc new-app docker.io/rocketchat/rocket.chat:0.63.3 -e MONGO_URL="mongodb://mongodb_user:mongodb_password@mongodb:27017/mongodb?replicaSet=rs0"
# mongoimport -d test -c shops mlbparks.json, nationalparks.json


if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

#Add role

oc policy add-role-to-group system:image-puller system:serviceaccounts:${GUID}-parks-prod -n ${GUID}-parks-prod
oc policy add-role-to-user edit system:serviceaccount:hong-cicd:jenkins -n ${GUID}-parks-prod
oc policy add-role-to-user view --serviceaccount=default -n ${GUID}-parks-prod

#Create MongoDB headless service

oc create -f "./Infrastructure/templates/setup_dev/mongohlsvc.yaml" -n ${GUID}-parks-prod
sleep 5s;

#Create MongoDB service

oc create -f "./Infrastructure/templates/setup_dev/mongosvc.yaml" -n ${GUID}-parks-prod
sleep 5s;

#Create MongoDB stateful set

oc create -f "./Infrastructure/templates/setup_dev/mongosfs.yaml" -n ${GUID}-parks-prod
sleep 5s;


#Build ParksMap apps

oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
sleep 5s;
oc expose svc parksmap-blue --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-prod

oc new-app ${GUID}-parks-prod/parksmap:0.0 --name=parksmap-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
sleep 5s;
oc expose svc parksmap-green --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-prod

oc delete configmap parksmap-blue-config -n ${GUID}-parks-prod --ignore-not-found=true
oc create configmap parksmap-blue-config --from-file=$HOME/Infrastructure/templates/setup_prod/parksmap-blue.properties -n ${GUID}-parks-prod

oc delete configmap parksmap-green-config -n ${GUID}-parks-prod --ignore-not-found=true
oc create configmap parksmap-green-config --from-file=$HOME/Infrastructure/templates/setup_prod/parksmap-green.properties -n ${GUID}-parks-prod

oc set volume dc/parksmap --add --name=parksmap-blue-config --configmap-name=parksmap-blue-config -n ${GUID}-parks-prod
sleep 5s;

oc set volume dc/parksmap --add --name=parksmap-green-config --configmap-name=parksmap-green-config -n ${GUID}-parks-prod
sleep 5s;


#Build NationalParks apps

oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
sleep 5s;
oc expose svc nationalparks-blue --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-prod

oc new-app ${GUID}-parks-prod/nationalparks:0.0 --name=nationalparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
sleep 5s;
oc expose svc nationalparks-green --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-prod

oc delete configmap nationalparks-blue-config -n ${GUID}-parks-prod --ignore-not-found=true
oc create configmap nationalparks-blue-config --from-file=$HOME/Infrastructure/templates/setup_prod/nationalparks-blue.properties -n ${GUID}-parks-prod

oc delete configmap nationalparks-green-config -n ${GUID}-parks-prod --ignore-not-found=true
oc create configmap nationalparks-green-config --from-file=$HOME/Infrastructure/templates/setup_prod/nationalparks-green.properties -n ${GUID}-parks-prod

oc set volume dc/nationalparks --add --name=nationalparks-blue-config --configmap-name=nationalparks-blue-config -n ${GUID}-parks-prod
sleep 5s;

oc set volume dc/nationalparks --add --name=nationalparks-green-config --configmap-name=nationalparks-green-config -n ${GUID}-parks-prod
sleep 5s;


#Build MLBParks apps

oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
sleep 5s;
oc expose svc mlbparks-blue --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-prod

oc new-app ${GUID}-parks-prod/mlbparks:0.0 --name=mlbparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
sleep 5s;
oc expose dc mlbparks-green --port 8080 --labels='type=parksmap-backend' -n ${GUID}-parks-prod

oc delete configmap mlbparks-blue-config -n ${GUID}-parks-prod --ignore-not-found=true
oc create configmap mlbparks-blue-config --from-file=./Infrastructure/templates/setup_prod/mlbparks-blue.properties -n ${GUID}-parks-prod

oc delete configmap mlbparks-green-config -n ${GUID}-parks-prod --ignore-not-found=true
oc create configmap mlbparks-green-config --from-file=./Infrastructure/templates/setup_prod/mlbparks-green.properties -n ${GUID}-parks-prod

oc set volume dc/mlbparks --add --name=mlbparks-blue-config --configmap-name=mlbparks-blue-config -n ${GUID}-parks-prod
sleep 5s;

oc set volume dc/mlbparks --add --name=mlbparks-green-config --configmap-name=mlbparks-green-config -n ${GUID}-parks-prod
sleep 5s;
