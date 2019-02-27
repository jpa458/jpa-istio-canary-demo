# jpa-istio-canary-demo

## Intro
A demo project for a 101 Kubernetes/Istio demo on the Google Cloud Platform.
In this demo we focus on canary releases and routing requests to different versions of a webservice.
A test server running from Cloud Shell allows you to visualise the different versions and watch a new version rollout in real time.

## Setup Instructions
* Create a GCP project and open Cloud Shell. Make sure your project is selected :

 `gcloud config set project <YOUR_PROJECT_ID>`

* Clone the repo into your cloud shell environment
```
git clone https://github.com/jpa458/jpa-istio-canary-demo
cd jpa-istio-canary-demo/setup
```

* Execute the setup.sh script - takes around 10mn to complete

 `./setup.sh`

* Open Web Preview from Cloud Shell and visualise the routing of requests to 2 different versions (blue/yellow) with a 80/20 weighting.

* Execute a rolling update with a new *red* version by running the following script and watch the version rollout in realtime in Web Preview.
```
cd ../updateVersion
./updateVersion.sh
```

## Disclaimer
* This is not an officially supported Google repo/product.
* This is a 101 intro to concepts allowing me to run demos.
* It is not a statement of best practices nor meant for production usage.
* Don't be that cut and paste coder!
