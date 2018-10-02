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

oc new-app --template=postgresql-persistent --param POSTGRESQL_USER=sonar --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar --param VOLUME_CAPACITY=4Gi --labels=app=sonarqube_db -n ${GUID}-sonarqube
sleep 5s;

oc new-app --docker-image=wkulhanek/sonarqube:6.7.4 --env=SONARQUBE_JDBC_USERNAME=sonar --env=SONARQUBE_JDBC_PASSWORD=sonar --env=SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar --labels=app=sonarqube -n ${GUID}-sonarqube

oc rollout pause dc sonarqube -n ${GUID}-sonarqube

echo "Sonarqube rollout paused"

oc set probe dc/sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok -n ${GUID}-sonarqube

echo "Setting first probe"

oc set probe dc/sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 20 --get-url=http://:9000/about -n ${GUID}-sonarqube

echo "Setting second probe"

oc rollout resume dc sonarqube -n ${GUID}-sonarqube
