variable "credentials_file_path" {
  description = "Credentials JSON file path"
  type        = string
}


variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = "wib-project-346915"
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central-1"
}

variable "network_name" {
  description = "Name of the Google Compute network"
  type        = string
  default     = "omer-network"
}

variable "subnet_name" {
  description = "Name of the Google Compute subnetwork"
  type        = string
  default     = "omer-subnet"
}

variable "subnet_ip_range" {
  description = "IP CIDR range for the subnetwork"
  type        = string
  default     = "10.1.0.0/24"
}

variable "master_template_name" {
  description = "Name of the Google Compute instance template for master nodes"
  type        = string
  default     = "omer-instance-master-template"
}

variable "worker_template_name" {
  description = "Name of the Google Compute instance template for worker nodes"
  type        = string
  default     = "omer-instance-worker-template"
}

variable "master_group_name" {
  description = "Name of the Google Compute instance group manager for master nodes"
  type        = string
  default     = "omer-instance-master-group"
}

variable "worker_group_name" {
  description = "Name of the Google Compute instance group manager for worker nodes"
  type        = string
  default     = "omer-instance-worker-group"
}

variable "master_disk_size" {
  description = "Size of the disk for master nodes"
  type        = number
  default     = 15
}

variable "worker_disk_size" {
  description = "Size of the disk for worker nodes"
  type        = number
  default     = 25
}

variable "firewall_egress_name" {
  description = "Name of the egress firewall rule"
  type        = string
  default     = "omer-kurl-network-requirements-firewall-egress"
}

variable "firewall_ingress_name" {
  description = "Name of the ingress firewall rule"
  type        = string
  default     = "omer-kurl-network-requirements-firewall-ingress"
}
