# jpa-istio-demo

## Intro
A demo project for a 101 Kubernetes/Istio demo project in Google Cloud Platform. We cover:
* Setting up the GCP project
* Creating a GKE cluster and installing Istio
* Deploying a simple webserver using network routing to direct traffic across 2 versions
* Creating a Cloud Build pipeline trigger on your git repo to trigger a build and deploy of a canary release

## Possible extensions to come
* Istio/Stackdriver integration and demo of SRE principles

## Disclaimer
* This is not an officially supported Google repo/product.
* This is a 101 intro to concepts allowing me to run demos.
* It is not a statement of best practices nor meant for production usage.
* Don't be that cut and paste coder!

## Instructions
* Start with *setupInstructions.md*
* Then move on to *cicdPipelineSetup.md*
* Simplest way to clean up is to delete the project 
