################################################################################
# Required APIs to be enabled
###############################################################################
resource "google_project_service" "kms" {
  project            = "dat-home-infra"
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = "dat-home-infra"
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  project            = "dat-home-infra"
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "k8s" {
  project            = "dat-home-infra"
  service            = "container.googleapis.com"
  disable_on_destroy = false
}
