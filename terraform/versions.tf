terraform {
  required_version = ">= 1.7.4"

  required_providers {
    google = ">= 5.19.0"
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = "${var.region}-a"
}