resource "google_storage_bucket" "artifacts" {
  name          = "${var.project_id}-ml-artifacts" # project IDs are globally unique, so this is too
  location      = upper(var.region)
  storage_class = "STANDARD"
  force_destroy = true # allow destroy even when old versions exist

  uniform_bucket_level_access = true       # IAM only, no per-object ACLs
  public_access_prevention    = "enforced" # can never be made public

  versioning {
    enabled = true
  }

  # Keep only the newest N old versions of each object
  lifecycle_rule {
    condition {
      num_newer_versions = var.keep_versions
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }

  # Clean up failed large uploads
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# Sample model artifact; changing var.model_version uploads a new version
resource "google_storage_bucket_object" "model" {
  bucket       = google_storage_bucket.artifacts.name
  name         = "models/${var.model_name}/model.json"
  content_type = "application/json"

  content = jsonencode({
    model_name    = var.model_name
    model_version = var.model_version
    framework     = "scikit-learn"
    metrics       = { accuracy = 0.956, roc_auc = 0.991 }
  })

  metadata = {
    model_version = var.model_version
  }
}
