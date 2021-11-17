
################################################################################
# GKE Setup
################################################################################
data "google_compute_default_service_account" "default" {}


resource "google_container_cluster" "gke-dev" {
  name                     = "testbed"
  location                 = "us-central1-c"
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "RAPID"
  }
  workload_identity_config {
    workload_pool = "dat-home-infra.svc.id.goog"
  }

}

resource "google_container_node_pool" "gke-dev-nodes" {
  cluster    = google_container_cluster.gke-dev.name
  name       = "${google_container_cluster.gke-dev.name}-node-pool"
  location   = "us-central1-c"
  node_count = 1

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = data.google_compute_default_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = ["gke-node", "dat-home-infra-gke"]
    labels = {
      env = "gke-env"
    }
  }
}
