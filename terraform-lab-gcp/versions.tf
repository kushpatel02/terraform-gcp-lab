terraform {
  required_version = ">= 1.7.0" # needed for mock providers in `terraform test`

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Remote state in a GCS bucket (created once with gcloud, see README).
  # The bucket name is passed at init time: terraform init -backend-config="bucket=<PROJECT_ID>-tfstate"
  # GCS backends lock the state automatically, so two applies can't run at once.
  backend "gcs" {
    prefix = "terraform-lab-gcp/state"
  }
}
