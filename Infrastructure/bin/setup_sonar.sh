#!/bin/bash
# Setup Sonarqube Project

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student

#Create a new PostgreSQL database
#Create a new SonarQube instance from docker.io/wkulhanek/sonarqube:6.7.4
#Configure SonarQube appropriately for resources, deployment strategy, persistent volumes, and readiness and liveness probes

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Sonarqube in project $GUID-sonarqube"

oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok -n ${GUID}-sonarqube

echo "Setting up Sonarqube in project $GUID-sonarqube"

oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about -n ${GUID}-sonarqube

echo "Setting up Sonarqube in project $GUID-sonarqube"

oc rollout resume dc sonarqube -n ${GUID}-sonarqube
