
terraform {
  required_version = ">=1.0.11"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "dat-home-infra"
  region  = "us-central1"
  zone    = "us-central1-c"
}

################################################################################
# Google Cloud KMS as Vault for Encrypting/Decrypting Secrets
################################################################################
resource "google_project_service" "kms" {
  project            = "dat-home-infra"
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_kms_key_ring" "sops-vault" {
  name     = "sops-vault"
  location = "us-central1"
  lifecycle {
    prevent_destroy = false

  }
  depends_on = [
    google_project_service.kms
  ]
}

resource "google_kms_crypto_key" "sops" {
  name     = "sops"
  key_ring = google_kms_key_ring.sops-vault.id
  lifecycle {
    prevent_destroy = false
  }
}

################################################################################
# IAM Setup
################################################################################
resource "google_project_service" "iam" {
  project            = "dat-home-infra"
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "flux" {
  account_id   = "flux-sops"
  display_name = "Flux SOPS Decrypter"
  description  = "SA for Flux in K8s to decrypt sensitive data"
}

resource "google_project_iam_binding" "flux" {
  project = "dat-home-infra"
  role    = "roles/cloudkms.cryptoKeyDecrypter"
  members = [
    "serviceAccount:${google_service_account.flux.email}",
  ]
}

# "container.googleapis.com",
#    "artifactregistry.googleapis.com",
#    "compute.googleapis.com",
