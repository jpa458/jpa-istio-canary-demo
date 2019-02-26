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

bold "Enabling APIs..."
gcloud services enable container.googleapis.com
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

bold "Installing SRE stack..."
wget -qO- https://github.com/istio/istio/releases/download/1.0.3/istio-1.0.3-linux.tar.gz | tar xvz
cd istio-1.0.3
kubectl apply -f install/kubernetes/istio-demo.yaml
kubectl label namespace default istio-injection=enabled

cd ..

bold "Building blue container image..."
gcloud builds submit --config cloud-build-image.yaml \
  --substitutions=_COLOUR=blue .

bold "Building yellow container image..."
sed -i "s/blue/yellow/g" ../webserver/server.js
gcloud builds submit --config cloud-build-image.yaml \
  --substitutions=_COLOUR=yellow .

bold "Patching manifests..."
sed -i "s/\/_PROJECT_ID/\/$PROJECT_ID/g" ./deployment.yaml

#bold "Starting deployments..."
kubectl apply -f deployment.yaml
kubectl apply -f gateway.yaml
kubectl apply -f routing-canary-20-yellow.yaml

bold "Deployment complete!"
#bold "Application url: http://storage.googleapis.com/$PROJECT_ID.appspot.com/coolretailer/ux.html"
#bold "API Endpoint: http://`kubectl -n istio-system get service istio-ingressgateway -o jsonpath={.status.loadBalancer.ingress[0].ip}|tail -1`/api/fetchProducts?name=go"
