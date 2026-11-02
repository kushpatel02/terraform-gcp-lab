output "artifact_bucket" {
  description = "Name of the model artifact bucket"
  value       = google_storage_bucket.artifacts.name
}

output "model_uri" {
  description = "gs:// URI of the model artifact"
  value       = "gs://${google_storage_bucket.artifacts.name}/${google_storage_bucket_object.model.name}"
}

output "vm_name" {
  value = google_compute_instance.vm.name
}

output "vm_zone" {
  value = google_compute_instance.vm.zone
}

output "vm_internal_ip" {
  description = "Private IP of the VM (it has no public IP)"
  value       = google_compute_instance.vm.network_interface[0].network_ip
}

output "vm_service_account" {
  value = google_service_account.vm.email
}

output "check_startup_command" {
  description = "Run this to see the VM's access-check results"
  value       = "gcloud compute instances get-serial-port-output ${google_compute_instance.vm.name} --zone ${google_compute_instance.vm.zone} | grep -E 'MODEL_READ|WRITE_'"
}

output "ssh_command" {
  description = "SSH into the VM through IAP"
  value       = "gcloud compute ssh ${google_compute_instance.vm.name} --zone ${google_compute_instance.vm.zone} --tunnel-through-iap"
}
