# checkov-test

## GCP Notes
Download the credentials then export the variable to point to the JSON file.

    export GOOGLE_APPLICATION_CREDENTIALS=~/.ssh/kubespray-rccl-6c31ddf6cafa.json

## Setup

Quickstart should be:

    make setup
    source python\_venv/bin/active
    export PATH=$(pwd)/bin:$PATH

Once setup, initialize the Terraform environment and apply. This example is in GCP and creates a free-tier resource.

    cd tf/gcp
    terraform init
    terraform apply

Return to the checkov base directory to run the scan.

    cd ../../
    checkov -d tf/gcp


To integrate bridgecrew visualization, go to bridgecrew.cloud then the API integrations and copy the key. IN PROGRESS
