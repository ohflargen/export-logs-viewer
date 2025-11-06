## Application Purpose:
The purpose of this application is to recieve instructions to download DICOM images from a GCP DICOM store. This code base was originally written by another developer, so a more thorough investigation is required when I, the developer, as Gemini for a solution or assistance. This application has been customized to use studyUrls to download DICOM images from a GCP DICOM store. There were originally a number of options to use for downloading images. 

## Application Architecture:
1. This application runs in a container on Google Cloud Platform running as a Cloud Run Service
2. The requests that drive this application are from a GCP Pub/Sub push Subscription

## Coding Practices:
1. Stay focused on the questions that are asked by myself, the developer. Deliver solutions to problems as narrowly as possible. Do not offer or recommend code changes that are outside the solution to the immediate problem. Wait until I, the developer, as you to review the code base and offer best practice guidance guidance before offering changes outside a solution to the immediate problem.

