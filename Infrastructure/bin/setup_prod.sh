#!/bin/bash
# Setup Production Project (initial active services: Green)
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

    Make the Green service active initially to guarantee a Blue rollout upon the first pipeline run


if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"
oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc mlbparks-blue --port 8080 -n ${GUID}-parks-prod
oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc mlbparks-green --port 8080 -n ${GUID}-parks-prod
oc expose svc/mlbparks-blue --name mlbparks -n ${GUID}-parks-prod
oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc nationalparks-blue --port 8080 -n ${GUID}-parks-prod
oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc nationalparks-green --port 8080 -n ${GUID}-parks-prod
oc expose svc/nationalparks-blue --name nationalparks -n ${GUID}-parks-prod
oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc parksmap-blue --port 8080 -n ${GUID}-parks-prod
oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc parksmap-green --port 8080 -n ${GUID}-parks-prod
oc expose svc/parksmap-blue --name parksmap -n ${GUID}-parks-prod
