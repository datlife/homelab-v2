################################################################################
# IAM Setup
################################################################################


################################################################################
# Allow Flux-System to read secret using GCP KMS
################################################################################
resource "google_service_account" "flux" {
  account_id   = "flux-sops"
  display_name = "Flux SOPS Decrypter"
  description  = "SA for Flux in K8s to decrypt sensitive data"
}

resource "google_project_iam_binding" "flux" {
  project = "dat-home-infra"
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${google_service_account.flux.email}",
  ]
}

resource "google_service_account_iam_binding" "flux-account-iam" {
  service_account_id = google_service_account.flux.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:dat-home-infra.svc.id.goog[flux-system/kustomize-controller]"
  ]
}

################################################################################
# Allow Grafana to Read data from BigQuery
################################################################################
resource "google_service_account" "grafana" {
  account_id   = "grafana-bigquery-reader"
  display_name = "Grafana BigQuery Reader"
  description  = "SA for Grafana"
}

resource "google_project_iam_binding" "grafana-data-read" {
  project = "dat-home-infra"
  role    = "roles/bigquery.dataViewer"
  members = [
    "serviceAccount:${google_service_account.grafana.email}",
  ]
}

resource "google_project_iam_binding" "grafana-job-user" {
  project = "dat-home-infra"
  role    = "roles/bigquery.jobUser"
  members = [
    "serviceAccount:${google_service_account.grafana.email}",
  ]
}

resource "google_service_account_iam_binding" "grafana-account-iam" {
  service_account_id = google_service_account.grafana.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:dat-home-infra.svc.id.goog[monitoring/grafana]"
  ]
}
