# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Project settings
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

# Network settings
variable "create_network" {
  description = "Whether to create a new network"
  type        = bool
  default     = true
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "jupyterhub-network"
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
  default     = "jupyterhub-subnet"
}

variable "subnetwork_cidr" {
  description = "CIDR range for the subnetwork"
  type        = string
  default     = "10.100.0.0/16"
}

# Cluster settings
variable "private_cluster" {
  description = "Whether to create a private cluster"
  type        = bool
  default     = false
}

variable "autopilot_cluster" {
  description = "Whether to create an autopilot cluster"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  description = "GKE Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "release_channel" {
  description = "GKE release channel (RAPID, REGULAR, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the GKE cluster"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "jupyterhub-cluster"
}

variable "cluster_location" {
  description = "Location (region or zone) for the GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "cluster_labels" {
  description = "Labels to apply to the GKE cluster"
  type        = map(string)
  default     = { "created-by" = "terraform", "app" = "jupyterhub" }
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master nodes (required for private clusters)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of CIDRs that can access the Kubernetes API server"
  type = list(object({
    cidr_block   = string
    display_name = optional(string)
  }))
  default = []
}

# Features
variable "gcs_fuse_csi_driver" {
  description = "Enable GCS FUSE CSI driver"
  type        = bool
  default     = true
}

variable "ray_addon_enabled" {
  description = "Enable Ray addon"
  type        = bool
  default     = false
}

variable "monitoring_enable_managed_prometheus" {
  description = "Enable GKE managed Prometheus"
  type        = bool
  default     = true
}

# Network settings for GKE
variable "ip_range_pods" {
  description = "CIDR range for pods"
  type        = string
  default     = ""
}

variable "ip_range_services" {
  description = "CIDR range for services"
  type        = string
  default     = ""
}

# JupyterHub settings
variable "jupyter_namespace" {
  description = "Kubernetes namespace for JupyterHub"
  type        = string
  default     = "jupyter"
}

variable "workload_identity_service_account" {
  description = "Name of the Workload Identity service account"
  type        = string
  default     = "jupyter-sa"
}

variable "notebook_image" {
  description = "Container image for Jupyter notebooks"
  type        = string
  default     = "jupyter/tensorflow-notebook"
}

variable "notebook_image_tag" {
  description = "Tag for the notebook image"
  type        = string
  default     = "python-3.10"
}

variable "ephemeral_storage" {
  description = "Amount of ephemeral storage for each user"
  type        = string
  default     = "20Gi"
}

variable "create_brand" {
  description = "Create a new OAuth brand for IAP (only needed when using IAP)"
  type        = bool
  default     = false
}

variable "support_email" {
  description = "Email for users to contact with questions about their consent (for IAP)"
  type        = string
  default     = "admin@example.com"
}
