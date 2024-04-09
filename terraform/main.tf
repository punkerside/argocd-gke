resource "google_compute_network" "main" {
  project                         = var.project
  name                            = var.name
  delete_default_routes_on_create = false
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
}

resource "google_compute_subnetwork" "main" {
  name          = var.name
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.main.id
}

resource "google_compute_router" "main" {
  name    = var.name
  region  = google_compute_subnetwork.main.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "main" {
  name                               = var.name
  router                             = google_compute_router.main.name
  region                             = google_compute_router.main.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.main.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "main" {
  project     = var.project
  name        = var.name
  network     = google_compute_network.main.id
  description = "firewall rule"

  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = var.name
  description   = var.name
  format        = "DOCKER"
}

resource "google_container_cluster" "main" {
  name                     = var.name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.main.name
  subnetwork               = google_compute_subnetwork.main.name
  deletion_protection      = false
}

resource "google_container_node_pool" "main" {
  name       = var.name
  location   = var.region
  cluster    = google_container_cluster.main.name
  
  version = data.google_container_engine_versions.main.release_channel_latest_version["STABLE"]
  node_count = 2

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/monitoring"
    ]

    machine_type = "n1-standard-1"
    disk_size_gb = 100

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

###

resource "google_service_account" "main" {
  project      = var.project
  account_id   = var.name
  display_name = var.name
}

resource "google_project_iam_member" "main" {
  project  = var.project
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${google_service_account.main.email}"
}