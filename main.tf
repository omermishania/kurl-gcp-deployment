provider "google" {
  credentials = file("/Users/omermishania/Downloads/wib-project-346915-d49f11e806ea.json")
  project     = "wib-project-346915"
  region      = "us-central-1"
}

resource "google_compute_network" "network" {
  name                    = "omer-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "omer-subnet"
  ip_cidr_range = "10.1.0.0/24"
  network       = google_compute_network.network.self_link
  region        = "us-central1"
}

resource "google_compute_instance_template" "template" {
  name = "omer-instance-template"
  tags = ["owner", "omer"]
  machine_type = "custom-4-8192"
  region       = "us-central1"
  disk {
      source_image = "centos-cloud/centos-stream-8"
      disk_size_gb = 30
  }
  network_interface {
    subnetwork = "omer-subnet"
        access_config {}
  }
}

resource "google_compute_instance_group_manager" "group" {
  name        = "omer-instance-group"
  base_instance_name = "omer-instance"
  zone        = "us-central1-a"
  version {
    instance_template = google_compute_instance_template.template.self_link
  }
  target_size = 1
}

resource "google_compute_firewall" "all_traffic_egress" {
  name    = "omer-kurl-network-requirements-firewall-egress"
  network = "omer-network"
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "all_traffic_ingress" {
  name    = "omer-kurl-network-requirements-firewall-ingress"
  network = "omer-network"
  allow {
    protocol = "all"
  }
  source_ranges = [ "0.0.0.0/0" ]
}