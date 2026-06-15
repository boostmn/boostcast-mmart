output "boostcast_mmart_ip" {
  description = "Static public IP of the VM. Point your DNS A record here."
  value       = google_compute_address.boostcast_mmart.address
}

output "boostcast_mmart_url" {
  description = "URL to reach the instance once DNS/HTTPS is set up (falls back to the raw IP)."
  value       = var.domain != "" ? "https://${var.domain}" : "http://${google_compute_address.boostcast_mmart.address}"
}
