# Dedicated identity for the VM instead of the broad default Compute Engine account
resource "google_service_account" "vm" {
  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "Terraform lab VM (read-only artifacts)"

  depends_on = [google_project_service.apis]
}

# Least privilege: read objects in this one bucket, nothing else
resource "google_storage_bucket_iam_member" "vm_reader" {
  bucket = google_storage_bucket.artifacts.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.vm.email}"
}
