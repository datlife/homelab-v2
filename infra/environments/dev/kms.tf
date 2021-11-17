
################################################################################
# Google Cloud KMS as Vault for Encrypting/Decrypting Secrets
###############################################################################
resource "google_kms_key_ring" "sops-vault" {
  name     = "sops-vault"
  location = "us-central1"
  depends_on = [
    google_project_service.kms
  ]
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "sops-key" {
  name     = "sops-key"
  key_ring = google_kms_key_ring.sops-vault.id
  lifecycle {
    prevent_destroy = false
  }
}
