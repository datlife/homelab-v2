
################################################################################
# GKE Setup
################################################################################
resource "google_container_cluster" "gke-dev" {
  project                  = "dat-home-infra"
  name                     = "testbed"
  location                 = "us-central1-c"
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "STABLE"
  }
  workload_identity_config {
    workload_pool = "dat-home-infra.svc.id.goog"
  }
}
resource "google_container_node_pool" "gke-dev-nodes" {
  project    = "dat-home-infra"
  cluster    = google_container_cluster.gke-dev.name
  name       = "${google_container_cluster.gke-dev.name}-node-pool"
  location   = "us-central1-c"
  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    preemptible  = true
    machine_type = "e2-medium"
    metadata = {
      disable-legacy-endpoints = "true"
    }
    tags = ["gke-node", "dat-home-infra-gke"]
    labels = {
      env = "gke-env"
    }
  }
}
