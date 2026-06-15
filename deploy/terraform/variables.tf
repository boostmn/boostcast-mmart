variable "project_id" {
  description = "GCP project ID to deploy into."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "asia-east2"
}

variable "zone" {
  description = "GCP zone."
  type        = string
  default     = "asia-east2-a"
}

variable "machine_type" {
  description = "VM machine type. e2-medium (2 vCPU/4GB) suits one station with light listenership; step up to e2-standard-2 (8GB) for multiple stations or live transcoding."
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB. Holds the database and uploaded media, so size for your library."
  type        = number
  default     = 50
}

variable "image" {
  description = "BoostCast container image to run."
  type        = string
  default     = "ghcr.io/boostmn/boostcast-mmart:latest"
}

variable "domain" {
  description = "Public domain for the station, e.g. radio.example.com. Leave empty to skip auto-HTTPS."
  type        = string
  default     = ""
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt registration (required if domain is set)."
  type        = string
  default     = ""
}

variable "mysql_password" {
  description = "Password for the BoostCast database user. Must be set before first boot."
  type        = string
  sensitive   = true
}
