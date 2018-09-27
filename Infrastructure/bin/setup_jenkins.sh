#!/bin/bash
# Setup Jenkins Project

# Code to set up the Jenkins project to execute the
# three pipelines.
# This will need to also build the custom Maven Slave Pod
# Image to be used in the pipelines.
# Finally the script needs to create three OpenShift Build
# Configurations in the Jenkins Project to build the
# three micro services. Expected name of the build configs:
# * mlbparks-pipeline
# * nationalparks-pipeline
# * parksmap-pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student


#Create a Jenkins instance with persistent storage and sufficient resources
#Create a build configuration to build the custom Maven slave pod to include Skopeo
#Set up three build configurations with pointers to the pipelines in the source code project.
#Each build configuration needs to point to the source code repository and the respective contextDir. The build configurations also need the following environment variables:
#GUID: The common GUID for all projects
#CLUSTER: The cluster base URL—for example, na39.openshift.opentlc.com



if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID REPO CLUSTER"
    echo "  Example: $0 wkha https://github.com/wkulhanek/ParksMap na39.openshift.opentlc.com"
    exit 1
fi

GUID=$1
REPO=$2
CLUSTER=$3
echo "Setting up Jenkins in project ${GUID}-jenkins from Git Repo ${REPO} for Cluster ${CLUSTER}"

#a. Create Jenkins app - without correct imagestream
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true -n ${GUID}-jenkins
sleep 5s;

#b. Download Docker registries config and Dockerfile for Docker image containing CentOS
#wget Dockerfile to $HOME/infrastructure/templates/Dockerfile ?
#wget registries.conf and override /etc/containers/registries.conf ?
#sudo -i
sudo systemctl enable docker
sudo systemctl start docker
wget https://raw.githubusercontent.com/honghuac/ocpadvdevhw/master/Infrastructure/templates/setup_jenkins/Dockerfile


#c. Build, Tag, Push Docker image
sudo docker build . -t docker-registry-default.apps.${CLUSTER}.openshift.opentlc.com/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.10
sleep 20s;
sudo docker login -u opentlc-mgr -p $(oc whoami -t) docker-registry-default.apps.${CLUSTER}.openshift.opentlc.com
sudo docker push docker-registry-default.apps.${CLUSTER}.openshift.opentlc.com/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.10
sleep 20s;

#d. Create build config for 3 Jenkin Pipeline apps
#wget ${REPO}/mlbparks-pipeline.yaml
#wget ${REPO}/nationalparks-pipeline.yaml
#wget ${REPO}/parksmap-pipeline.yaml

oc create -f "./Infrastructure/templates/setup_jenkins/mlbparks-pipeline.yaml"
sleep 5s;

oc create -f "./Infrastructure/templates/setup_jenkins/nationalparks-pipeline.yaml"
sleep 5s;

oc create -f "./Infrastructure/templates/setup_jenkins/parksmap-pipeline.yaml"
sleep 5s;
