# Always use the latest Debian 12 image instead of a hardcoded (and aging) one
data "google_compute_image" "debian" {
  family  = "debian-12"
  project = "debian-cloud"
}

resource "google_compute_instance" "vm" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["ssh-iap"]

  allow_stopping_for_update = true # lets Terraform change machine_type in place

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = var.boot_disk_gb
      type  = "pd-standard"
    }
  }

  # No access_config block -> no public IP
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"] # actual permissions come from IAM, not scopes
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    model_uri = "gs://${google_storage_bucket.artifacts.name}/${google_storage_bucket_object.model.name}"
    bucket    = google_storage_bucket.artifacts.name
  })

  # The VM checks bucket access on boot, so permissions and the model must exist first
  depends_on = [google_storage_bucket_iam_member.vm_reader, google_storage_bucket_object.model]
}
