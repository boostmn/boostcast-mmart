# BoostCast — Terraform deployment (Google Compute Engine)

Provisions a Compute Engine VM that self-installs Docker and runs the
`ghcr.io/boostmn/boostcast-mmart` all-in-one image, plus a static IP and
firewall rules for the web UI and station streaming ports.

## What it creates

- `google_compute_address.boostcast_mmart` — static public IP
- `google_compute_firewall.web` — TCP 80, 443, 2022
- `google_compute_firewall.streams` — TCP 8000–8500 (station streams)
- `google_compute_instance.boostcast-mmart` — Ubuntu 24.04 VM that runs the
  container via a startup script

## Prerequisites

- A GCP project with billing enabled
- `terraform >= 1.5` and the `gcloud` CLI
- Credentials for Terraform:
  ```bash
  gcloud auth application-default login
  gcloud services enable compute.googleapis.com
  ```

## Usage

```bash
cd deploy/terraform
cp terraform.tfvars.example terraform.tfvars   # then edit it
terraform init
terraform plan
terraform apply
terraform output boostcast_mmart_ip            # set your DNS A record to this
```

After `apply`, the VM installs Docker and starts BoostCast automatically (no
SSH needed). Point your domain's A record at the output IP, then open the URL
to finish the setup wizard.

## Notes

- **Secrets/state:** `terraform.tfvars` and `*.tfstate` are gitignored. State
  contains the DB password — for a team, configure a remote
  [GCS backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).
- **HTTPS:** set `domain` + `letsencrypt_email` to auto-provision a TLS cert.
- **Updates:** the startup script only runs on first boot, so changing `image`
  won't recreate the container. To update, SSH in and re-pull:
  ```bash
  docker pull ghcr.io/boostmn/boostcast-mmart:latest
  docker rm -f boostcast-mmart   # volumes persist
  # re-run the docker run command from startup-script.sh.tftpl
  ```
- **Teardown:** `terraform destroy` removes the VM, IP, and firewall rules.
  Docker named volumes live on the VM's disk and are deleted with it — back up
  first if you need the data.
