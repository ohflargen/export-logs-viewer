## local conda env
hai-container

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
IMG=dicom-downloader:v48
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

## Cloud Run instances
dev = https://dev-dicom-downloader-4489067101.us-central1.run.app
prod = https://prod-dicom-downloader-4489067101.us-central1.run.app

## local testing

docker run -e GOOGLE_APPLICATION_CREDENTIALS=/Users/walter.matthew/opus/keys/aif-usr-p-itaia3i-98be-mkw13.json \
           -v /Users/walter.matthew/opus/keys/aif-usr-p-itaia3i-98be-mkw13.json:/Users/walter.matthew/opus/keys/aif-usr-p-itaia3i-98be-mkw13.json \
           --platform linux/amd64 -p 5000:5000 $TAG

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" http://localhost:5000


curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"30day-data-98b3", "env": "development", "app": "30d", "runID": "20250729-061501", "studyUrl": "https://healthcare.googleapis.com/v1/projects/ml-mps-adl-arestricted-p-9bb6/locations/us/datasets/ml-int-mcr-midia-us-p/dicomStores/ml-int-mcr-midia-us-p-dicom-mcr-allradiologyorguln/dicomWeb/studies/1.2.840.114350.2.451.2.798268.2.2223648358829.1"}' http://localhost:5000//get-dicom-study

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"hai-data-98b3", "env": "development", "app": "30d", "runID": "00000000-000000", "studyUrl": "https://healthcare.googleapis.com/v1/projects/ml-mps-adl-arestricted-p-9bb6/locations/us/datasets/ml-int-mcr-midia-us-p/dicomStores/ml-int-mcr-midia-us-p-dicom-mcr-allradiologyorguln/dicomWeb/studies/1.2.840.114350.2.451.2.798268.2.2223648358829.1"}' http://localhost:5000//dicom-load

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"30day-data-98b3", "env": "staging", "app": "30d", "runID": "00000000-000010", "csv_path": "gs://30day-data-98b3/staging/00000000-000010/load/clinic_and_accession_numbers.csv"}' http://localhost:5000//get-dicom-by-accession-csv

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"30day-data-98b3", "env": "staging", "app": "30d", "runID": "00000000-000011", "csv_path": "gs://30day-data-98b3/staging/00000000-000010/load/clinic_and_accession_numbers_half.csv"}' http://localhost:5000//get-dicom-by-accession-csv

## Local pub/sub testing
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST \
  -H "Content-Type: application/json" \
  -d @scripts/payload_direct.json \
  https://dev-dicom-downloader-4489067101.us-central1.run.app/get-dicom-study

## Development Environment testing

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"30day-data-98b3", "env": "staging", "app": "30d", "runID": "00000000-000020", "csv_path": "gs://30day-data-98b3/staging/00000000-000020/load/clinic_and_accession_numbers.csv"}' https://dev-dicom-downloader-4489067101.us-central1.run.app//get-dicom-by-accession-csv

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"hai-data-98b3", "env": "development", "app": "30d", "runID": "00000000-000000", "studyUrl": "https://healthcare.googleapis.com/v1/projects/ml-mps-adl-arestricted-p-9bb6/locations/us/datasets/ml-int-mcr-midia-us-p/dicomStores/ml-int-mcr-midia-us-p-dicom-mcr-allradiologyorguln/dicomWeb/studies/1.2.840.114350.2.451.2.798268.2.2223648358829.1" }' https://dev-dicom-downloader-4489067101.us-central1.run.app/dicom-load

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "bucket":"30day-data-98b3", "env": "development", "app": "30d", "runID": "20250717-175236", "studyUrl": "https://healthcare.googleapis.com/v1/projects/ml-mps-adl-arestricted-p-9bb6/locations/us/datasets/ml-int-mcr-midia-us-p/dicomStores/ml-int-mcr-midia-us-p-dicom-mcr-allradiologyorguln/dicomWeb/studies/1.2.840.114350.2.451.2.798268.2.2223648358829.1"}' https://dev-dicom-downloader-4489067101.us-central1.run.app/dicom-load

## DICOM file path
{env}/{runID}/dicom/{PatientID}/{AccessionNumber}/{StudyInstanceUID}/{SeriesInstanceUID}/{SOPInstanceUID}.dcm

curl -X POST \
  -H "Content-Type: application/json" --request POST --data '{ "csv_path": "/app/data/study_urls_batch_1.csv", "bucket": "30day-data-98b3", "app": "30d", "env": "adhoc", "runID": "20251017-000001" }' \
  http://127.0.0.1:5000/get-dicom-from-csv


curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "csv_path": "/app/data/study_urls_batch_1.csv", "bucket": "30day-data-98b3", "app": "30d", "env": "adhoc", "runID": "20251017-000001" }' https://dev-dicom-downloader-4489067101.us-central1.run.app/get-dicom-from-csv

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "csv_path": "/app/data/study_urls_batch_2.csv", "bucket": "30day-data-98b3", "app": "30d", "env": "adhoc", "runID": "20251017-000002" }' https://dev-dicom-downloader-4489067101.us-central1.run.app/get-dicom-from-csv

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "csv_path": "/app/data/study_urls_batch_3.csv", "bucket": "30day-data-98b3", "app": "30d", "env": "adhoc", "runID": "20251017-000003" }' https://dev-dicom-downloader-4489067101.us-central1.run.app/get-dicom-from-csv

curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" --header "Content-Type: application/json" --request POST --data '{ "csv_path": "/app/data/study_urls_batch_4.csv", "bucket": "30day-data-98b3", "app": "30d", "env": "adhoc", "runID": "20251017-000004" }' https://dev-dicom-downloader-4489067101.us-central1.run.app/get-dicom-from-csv


{
    "csv_path": "/app/data/study_urls_batch_1.csv", "bucket": "30day-data-98b3", "app": "30d", "env": "adhoc", "runID": "20251017-000001"
}