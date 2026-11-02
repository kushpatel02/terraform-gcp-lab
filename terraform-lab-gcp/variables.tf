variable "project_id" {
  description = "GCP project ID to deploy into"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "region" {
  description = "Region for the subnet and bucket. Limited to regions where e2-micro is free tier."
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.region)
    error_message = "region must be one of us-central1, us-east1, us-west1 (e2-micro free tier regions)."
  }
}

variable "zone" {
  description = "Zone for the VM (must be inside var.region)"
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = can(regex("^us-(central1|east1|west1)-[a-f]$", var.zone))
    error_message = "zone must be a zone in us-central1, us-east1 or us-west1, e.g. us-central1-a."
  }
}

variable "environment" {
  description = "Environment label applied to all resources"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "tf-lab"
}

variable "machine_type" {
  description = "VM machine type. Restricted to small shared-core types to control cost."
  type        = string
  default     = "e2-micro"

  validation {
    condition     = contains(["e2-micro", "e2-small", "e2-medium"], var.machine_type)
    error_message = "machine_type must be e2-micro, e2-small or e2-medium."
  }
}

variable "boot_disk_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10

  validation {
    condition     = var.boot_disk_gb >= 10 && var.boot_disk_gb <= 30
    error_message = "boot_disk_gb must be between 10 and 30 (30 GB standard disk is free tier)."
  }
}

variable "model_name" {
  description = "Name of the model artifact stored in the bucket"
  type        = string
  default     = "breast-cancer-classifier"
}

variable "model_version" {
  description = "Semantic version of the model artifact. Changing it uploads a new object version."
  type        = string
  default     = "1.0.0"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.model_version))
    error_message = "model_version must look like MAJOR.MINOR.PATCH, e.g. 1.0.0."
  }
}

variable "keep_versions" {
  description = "How many older (noncurrent) versions of each object to keep before deletion"
  type        = number
  default     = 3

  validation {
    condition     = var.keep_versions >= 1 && var.keep_versions <= 10
    error_message = "keep_versions must be between 1 and 10."
  }
}
