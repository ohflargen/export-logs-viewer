## local conda env
web-ui

## Docker Image

## Cloud Run Instance

## MUST do for running queries local

gcloud auth application-default login
gcloud auth login --update-adc
gcloud auth activate-service-account --key-file /Users/walter.matthew/opus/keys/aif-usr-p-itaia3i-98be-mkw13.json

SSL cert setup
gsutil cp gs://aif_shared_bucket_p_00/ssl/CertEmulationCA.crt .

## Build Image

REGION="us-central1"
PROJECT_ID=$(gcloud config get project)
PROJECT_HASH="${PROJECT_ID##\*-}"
REPOSITORY="shared-aif-artifact-registry-docker-98be"
IMG=export-logs-viewer:v1
TAG="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMG"

docker buildx build --platform linux/amd64 --file Dockerfile --tag=$TAG .

## Push Image

docker push $TAG

## Deploy/Edit Cloud Run instance

gcloud run deploy hai-bq-int \
--image=$TAG \
--region=us-central1 \
--project=aif-usr-p-itaia3i-98be \
 && gcloud run services update-traffic hai-bq-int --to-latest

## Create Cloud Run Service

SA=gsa6-va-prj-aif-p-98be@$PROJECT_ID.iam.gserviceaccount.com
VPC_CONNECTOR=projects/aif-env-sharedvpc-148f/locations/us-central1/connectors/aif-vpc-p-ops-auto-01

gcloud run deploy prod-dicom-downloader \
 --image=$TAG \
  --port=5000 \
  --service-account=$SA \
 --max-instances=10 \
 --vpc-connector=$VPC_CONNECTOR  \
  --vpc-egress=all-traffic \
  --binary-authorization default \
  --cpu-boost \
  --memory=4Gi \
  --cpu=1 \
  --ingress=internal-and-cloud-load-balancing \
  --region=us-central1 \
  --project=$PROJECT_ID
