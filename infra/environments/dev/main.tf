
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
