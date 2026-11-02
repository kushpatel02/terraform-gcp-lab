# Custom VPC instead of the "default" network (which allows SSH/RDP from anywhere)
resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.apis]
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"

  # Lets the VM reach Cloud Storage without a public IP
  private_ip_google_access = true
}

# SSH only through Identity-Aware Proxy, never from the open internet
resource "google_compute_firewall" "iap_ssh" {
  name    = "${var.name_prefix}-allow-iap-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # Google's IAP range
  target_tags   = ["ssh-iap"]
}
