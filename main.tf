provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project_id
  region      = var.region
}

resource "google_compute_network" "network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_range
  network       = google_compute_network.network.self_link
  region        = var.region
}

resource "google_compute_instance_template" "master-template" {
  name         = var.master_template_name
  tags         = ["owner", "omer"]
  machine_type = "custom-${var.instance_cpu_count}-${var.instance_memory_gb * 1024}"
  region       = var.region
  disk {
    source_image = "centos-cloud/centos-stream-8"
    disk_size_gb = var.master_root_disk_size
  }
  disk {
    disk_size_gb = var.master_unformatted_disk_size
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {}
  }
  depends_on = [google_compute_network.network, google_compute_subnetwork.subnet]
}

resource "google_compute_instance_group_manager" "master-group" {
  name               = var.master_group_name
  base_instance_name = "omer-master-instance"
  zone               = "us-central1-a"
  version {
    instance_template = google_compute_instance_template.master-template.self_link
  }
  target_size = var.master_group_target_size
}

resource "google_compute_instance_template" "worker-template" {
  name         = var.worker_template_name
  tags         = ["owner", "omer"]
  machine_type = "custom-${var.instance_cpu_count}-${var.instance_memory_gb * 1024}"
  region       = var.region
  disk {
    source_image = "centos-cloud/centos-stream-8"
    disk_size_gb = var.worker_root_disk_size
  }
  disk {
    disk_size_gb = var.worker_unformatted_disk_size
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {}
  }
  depends_on = [google_compute_network.network, google_compute_subnetwork.subnet]
}

resource "google_compute_instance_group_manager" "worker-group" {
  name               = var.worker_group_name
  base_instance_name = "omer-worker-instance"
  zone               = "us-central1-a"
  version {
    instance_template = google_compute_instance_template.worker-template.self_link
  }
  target_size = var.worker_group_target_size
}

resource "google_compute_firewall" "all_traffic_egress" {
  name    = var.firewall_egress_name
  network = var.network_name
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "all_traffic_ingress" {
  name    = var.firewall_ingress_name
  network = var.network_name
  allow {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
}
