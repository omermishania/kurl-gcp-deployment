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

# Master node template
resource "google_compute_instance_template" "master-template" {
  name = "omer-instance-master-template"
  tags = ["owner", "omer"]
  machine_type = "custom-4-8192"
  region       = "us-central1"
  disk {
      source_image = "centos-cloud/centos-stream-8"
      disk_size_gb = 32
  }
  disk {
      disk_size_gb = 15
      # ADD UNFORMATTED BLOCK DEVICE FOR ROOK
  }
  network_interface {
    subnetwork = "omer-subnet"
        access_config {}
  }
  metadata_startup_script = <<-EOF
  curl -sSL https://kurl.sh/b58a0f8 | sudo bash
  EOF
  depends_on = [google_compute_network.network, google_compute_subnetwork.subnet]
}

# Master node group manager
resource "google_compute_instance_group_manager" "master-group" {
  name        = "omer-instance-master-group"
  base_instance_name = "omer-master-instance"
  zone        = "us-central1-a"
  version {
    instance_template = google_compute_instance_template.master-template.self_link
  }
  target_size = 1
}

# Worker node template
resource "google_compute_instance_template" "worker-template" {
  name = "omer-instance-worker-template"
  tags = ["owner", "omer"]
  machine_type = "custom-4-8192"
  region       = "us-central1"
  disk {
      source_image = "centos-cloud/centos-stream-8"
      disk_size_gb = 64
  }
  disk {
      disk_size_gb = 25
      # ADD UNFORMATTED BLOCK DEVICE FOR ROOK
  }
  network_interface {
    subnetwork = "omer-subnet"
        access_config {}
  }
  depends_on = [google_compute_network.network, google_compute_subnetwork.subnet]
}

# Worker node group manager
resource "google_compute_instance_group_manager" "worker-group" {
  name        = "omer-instance-worker-group"
  base_instance_name = "omer-worker-instance"
  zone        = "us-central1-a"
  version {
    instance_template = google_compute_instance_template.worker-template.self_link
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