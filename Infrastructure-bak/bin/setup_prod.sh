#!/bin/bash
# Setup Production Project (initial active services: Green)
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Parks Production Environment in project ${GUID}-parks-prod"

# Code to set up the parks production project. It will need a StatefulSet MongoDB, and two applications each (Blue/Green) for NationalParks, MLBParks and Parksmap.
# The Green services/routes need to be active initially to guarantee a successful grading pipeline run.

# To be Implemented by Student

# Create mlbparks Blue Application
oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc mlbparks-blue --port 8080 -n ${GUID}-parks-prod

# Create mlbparks Green Application
oc new-app ${GUID}-parks-dev/mlbparks:0.0 --name=mlbparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc mlbparks-green --port 8080 -n ${GUID}-parks-prod

# Expose mlbparks Blue service as route to make blue application active
oc expose svc/mlbparks-blue --name mlbparks -n ${GUID}-parks-prod

# Create nationalparks Blue Application
oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc nationalparks-blue --port 8080 -n ${GUID}-parks-prod

# Create nationalparks Green Application
oc new-app ${GUID}-parks-dev/nationalparks:0.0 --name=nationalparks-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc nationalparks-green --port 8080 -n ${GUID}-parks-prod

# Expose nationalparks Blue service as route to make blue application active
oc expose svc/nationalparks-blue --name nationalparks -n ${GUID}-parks-prod

# Create parksmap Blue Application
oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-blue --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc parksmap-blue --port 8080 -n ${GUID}-parks-prod

# Create parksmap Green Application
oc new-app ${GUID}-parks-dev/parksmap:0.0 --name=parksmap-green --allow-missing-imagestream-tags=true -n ${GUID}-parks-prod
oc expose dc parksmap-green --port 8080 -n ${GUID}-parks-prod

# Expose parksmap Blue service as route to make blue application active
oc expose svc/parksmap-blue --name parksmap -n ${GUID}-parks-prod
