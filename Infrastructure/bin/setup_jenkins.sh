#!/bin/bash
# Setup Jenkins Project
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
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi -n ${GUID}-jenkins
oc new-app openshift/jenkins-slave-maven-centos7:v3.10
oc new-app mlbparks-pipeline
oc new-app natparks-pipeline
oc new-app parksmap-pipeline

#b. Create Dockerfile for Docker image containing CentOS
#FROM docker.io/openshift/jenkins-slave-maven-centos7:v3.9
#USER root
#RUN yum -y install skopeo apb && \
#    yum clean all
#USER 1001

#c. Build, Tag, Push Docker image
#docker build . -t docker-registry-default.apps.dev39.openshift.opentlc.com/hong-cicd/jenkins-slave-maven-appdev:v3.9
#docker push docker-registry-default.apps.dev39.openshift.opentlc.com/hong-cicd/jenkins-slave-maven-appdev:v3.9
