#!/bin/bash
# Setup from scratch via script
#
bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

err() {
  echo "$*" >&2;
}

source ./properties

if [ -z "$PROJECT_ID" ]; then
  err "Not running in a GCP project. Please run gcloud config set project $PROJECT_ID."
  exit 1
fi

bold "Starting the setup process in project $PROJECT_ID..."

bold "Enabling Container APIs..."
gcloud services enable container.googleapis.com
bold "Enabling Cloud Build APIs..."
gcloud services enable cloudbuild.googleapis.com

bold "Creating cluster..."
gcloud beta container clusters create $GKE_CLUSTER \
  --zone $ZONE \
  --cluster-version=latest \
  --num-nodes 5

gcloud container clusters get-credentials $GKE_CLUSTER --zone $ZONE

bold "Create role bindings..."
kubectl create clusterrolebinding cluster-admin-binding \
 --clusterrole=cluster-admin \
 --user=$(gcloud config get-value core/account)

bold "Installing Istio..."
wget -qO- https://github.com/istio/istio/releases/download/1.1.0-rc.1/istio-1.1.0-rc.1-linux.tar.gz | tar xvz
cd istio-1.1.0-rc.1
kubectl apply -f install/kubernetes/istio-demo.yaml
kubectl label namespace default istio-injection=enabled
cd ..

bold "Building blue container image..."
gcloud builds submit --config cloud-build-image.yaml \
  --substitutions=_COLOUR=blue ../webserver

bold "Building yellow container image..."
sed -i "s/blue/yellow/g" ../webserver/server.js
gcloud builds submit --config cloud-build-image.yaml \
  --substitutions=_COLOUR=yellow ../webserver

bold "Patching files with correct project id..."
sed -i "s/\/_PROJECT_ID/\/$PROJECT_ID/g" ./deployment.yaml

#bold "Starting deployments..."
kubectl apply -f deployment.yaml
kubectl apply -f gateway.yaml
kubectl apply -f routing-canary-20-yellow.yaml

bold "Deployment complete!"
SERVICE_IP_ADDRESS=`kubectl -n istio-system get service istio-ingressgateway -o jsonpath={.status..ingress[0].ip}`
bold "API Endpoint: http://$SERVICE_IP_ADDRESS/"

bold "Starting local webserver to visualise routing rules..."
cd ../localTestServer
#set the ip address to the public ingress gateway IP address
sed -i "s/SERVICE_IP_ADDRESS/$SERVICE_IP_ADDRESS/g" ./demo.html
npm install
node server.js &
bold "Open web preview on port 8080 from cloud console to visualise the routing to blue and yellow versions."
bold "You will need to enable the loading of unsafe scripts becuase web preview uses HTTPS and we have not set an HTTPS enabled ingress gateway - TODO :)."
