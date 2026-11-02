provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Applied to every resource that supports labels
  default_labels = {
    managed_by  = "terraform"
    environment = var.environment
    course      = "mlops"
  }
}
