# Offline tests: the Google provider is mocked, so nothing is created and no credentials are needed.
# Run: terraform init -backend=false && terraform test

mock_provider "google" {
  mock_data "google_compute_image" {
    defaults = {
      self_link = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-12-mock"
    }
  }
}

variables {
  project_id = "test-project-123"
}

run "bucket_is_private_versioned_and_cleaned_up" {
  assert {
    condition     = google_storage_bucket.artifacts.name == "test-project-123-ml-artifacts"
    error_message = "Bucket name should be <project_id>-ml-artifacts"
  }
  assert {
    condition     = google_storage_bucket.artifacts.versioning[0].enabled
    error_message = "Versioning must be enabled"
  }
  assert {
    condition     = google_storage_bucket.artifacts.public_access_prevention == "enforced"
    error_message = "Public access prevention must be enforced"
  }
  assert {
    condition     = google_storage_bucket.artifacts.uniform_bucket_level_access
    error_message = "Uniform bucket-level access must be on"
  }
  assert {
    condition     = one(google_storage_bucket.artifacts.lifecycle_rule[0].condition).num_newer_versions == 3
    error_message = "Should keep 3 noncurrent versions by default"
  }
}

run "vm_is_private_and_least_privilege" {
  assert {
    condition     = length(google_compute_instance.vm.network_interface[0].access_config) == 0
    error_message = "VM must not have a public IP"
  }
  assert {
    condition     = google_compute_instance.vm.service_account[0].email == google_service_account.vm.email
    error_message = "VM must use the dedicated service account"
  }
  assert {
    condition     = google_storage_bucket_iam_member.vm_reader.role == "roles/storage.objectViewer"
    error_message = "VM access must be read-only"
  }
  assert {
    condition     = google_compute_instance.vm.machine_type == "e2-micro"
    error_message = "Default machine type should be e2-micro"
  }
}

run "ssh_only_from_iap" {
  assert {
    condition     = google_compute_firewall.iap_ssh.source_ranges == toset(["35.235.240.0/20"])
    error_message = "SSH must only be allowed from the IAP range"
  }
}

run "model_version_flows_into_artifact" {
  variables {
    model_version = "2.0.0"
  }
  assert {
    condition     = google_storage_bucket_object.model.metadata["model_version"] == "2.0.0"
    error_message = "Object metadata should carry the model version"
  }
}

run "rejects_expensive_machine_type" {
  command = plan
  variables {
    machine_type = "n2-standard-8"
  }
  expect_failures = [var.machine_type]
}

run "rejects_bad_model_version" {
  command = plan
  variables {
    model_version = "v1"
  }
  expect_failures = [var.model_version]
}
