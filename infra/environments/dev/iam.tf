################################################################################
# IAM Setup
################################################################################
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

resource "google_service_account_iam_binding" "flux-account-iam" {
  service_account_id = google_service_account.flux.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:dat-homelab.svc.id.goog[flux-system/kustomize-controller]"
  ]
}
