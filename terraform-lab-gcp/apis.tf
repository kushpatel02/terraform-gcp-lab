# Enable the APIs this config needs, instead of clicking through the console.
resource "google_project_service" "apis" {
  for_each = toset(["compute.googleapis.com", "iam.googleapis.com"])

  service            = each.value
  disable_on_destroy = false # keep APIs on after destroy; disabling can break other things in the project
}
