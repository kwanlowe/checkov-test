# checkov-test

Quickstart should be:

    make setup
	source setup.env

Once setup, initialize the Terraform environment and apply. This example is in GCP and creates a free-tier resource.

    cd tf/gcp
    terraform init
    terraform apply

Return to the checkov base directory to run the scan.

    cd ../../
    checkov -d tf/gcp


To integrate bridgecrew visualization, go to bridgecrew.cloud then the API integrations and copy the key. IN PROGRESS
