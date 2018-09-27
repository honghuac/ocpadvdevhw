#!/bin/bash
# Setup Grading Jenkins Project

# Code to set up the Jenkins project to execute the grading Jenkins pipeline
# The build configurations need to have two environment variables to be passed to the Pipeline:
# * GUID: the GUID used in all the projects
# * CLUSTER: the base url of the cluster used (e.g. na39.openshift.opentlc.com)

# To be Implemented by Student

#Create a Jenkins instance with persistent storage and sufficient resources
#Create a build configuration to build the custom Maven slave pod to include Skopeo
#Add permission to allow grading-jenkins to view other projects
#GUID: The common GUID for all projects
#CLUSTER: The cluster base URL—for example, na39.openshift.opentlc.com


if [ "$#" -ne 3 ]; then
    echo "Usage:"
    echo "  $0 GUID CLUSTER USER"
    echo "  Example: $0 wkha na39.openshift.opentlc.com wkha-redhat.com"
    exit 1
fi

GUID=$1
CLUSTER=$2
USER=$3
echo "Setting up Jenkins in project ${GUID}-jenkins for Cluster ${CLUSTER} for user ${USER}"

#Create new Grading Jenkins project and assign roles
oc new-project ${GUID}-jenkins --display-name="${GUID} AdvDev Homework Grading Jenkins"
oc policy add-role-to-user admin ${USER} -n ${GUID}-jenkins
oc annotate namespace ${GUID}-jenkins openshift.io/requester=${USER} --overwrite
oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:${GUID}-jenkins:jenkins

#a. Create Jenkins app - without correct imagestream
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true -n ${GUID}-jenkins
sleep 5s;

#b. Download Docker registries config and Dockerfile for Docker image containing CentOS
#wget Dockerfile to $HOME/infrastructure/templates/Dockerfile ?
#wget registries.conf and override /etc/containers/registries.conf ?
sudo -i
systemctl enable docker
systemctl start docker
cd $HOME/infrastructure/templates/

#c. Build, Tag, Push Docker image
docker build . -t docker-registry-default.apps.${GUID}.openshift.opentlc.com/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.10
sleep 20s;
docker login -u opentlc-mgr -p $(oc whoami -t) docker-registry-default.apps.${GUID}.openshift.opentlc.com
docker push docker-registry-default.apps.$GUID.openshift.opentlc.com/${GUID}-jenkins/jenkins-slave-maven-appdev:v3.10
