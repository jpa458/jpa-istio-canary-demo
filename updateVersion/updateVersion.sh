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

bold "Setup IAM policy so cloud build can deploy to the cluster"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com --role roles/container.admin

bold "Starting the update process in project $PROJECT_ID..."

bold "Building red container image and deploying to the cluster"

sed -i "s/yellow/red/g" ../webserver/server.js
gcloud builds submit --config cloud-build-update-version.yaml \
  --substitutions=_ZONE=$ZONE,_GKE_CLUSTER=$GKE_CLUSTER ../webserver

bold "Deployment complete! Monitor the test page to watch the new version rollout."
