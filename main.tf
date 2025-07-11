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

# Configure Google Cloud providers
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Required for accessing the cluster credentials
data "google_client_config" "default" {}

# Step 1: Create the GKE cluster using the infrastructure module
module "infrastructure" {
  source = "./common/infrastructure"

  # Load values from tfvars
  project_id                           = var.project_id
  create_network                       = var.create_network
  network_name                         = var.network_name
  subnetwork_name                      = var.subnetwork_name
  subnetwork_region                    = var.region
  subnetwork_cidr                      = var.subnetwork_cidr
  private_cluster                      = var.private_cluster
  autopilot_cluster                    = var.autopilot_cluster
  cluster_name                         = var.cluster_name
  cluster_location                     = var.cluster_location
  cluster_labels                       = var.cluster_labels
  kubernetes_version                   = var.kubernetes_version
  release_channel                      = var.release_channel
  ip_range_pods                        = var.ip_range_pods
  ip_range_services                    = var.ip_range_services
  master_ipv4_cidr_block               = var.master_ipv4_cidr_block
  master_authorized_networks           = var.master_authorized_networks
  monitoring_enable_managed_prometheus = var.monitoring_enable_managed_prometheus
  gcs_fuse_csi_driver                  = var.gcs_fuse_csi_driver
  ray_addon_enabled                    = var.ray_addon_enabled
  deletion_protection                  = var.deletion_protection
  create_cluster                       = true
}

# Configure Kubernetes provider to use the newly created cluster.
# We use the alias to differentiate it from jupyter.versions provider.
provider "kubernetes" {
  alias                  = "jupyter"
  host                   = "https://${module.infrastructure.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.infrastructure.ca_certificate)
}

# Configure Helm provider (required for JupyterHub installation)
provider "helm" {
  alias = "jupyter"
  kubernetes {
    host                   = "https://${module.infrastructure.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.infrastructure.ca_certificate)
  }
}

resource "kubernetes_namespace" "jupyter" {
  provider = kubernetes.jupyter
  metadata {
    name = var.jupyter_namespace
  }
  depends_on = [module.infrastructure]
}

# Step 2: Create GCS bucket for JupyterHub data
resource "google_storage_bucket" "jupyter_bucket" {
  name          = "${var.project_id}-jupyter-data"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

# Step 3: Deploy JupyterHub on the cluster
module "jupyter" {
  source = "./common/modules/jupyter"

  # Use the configured provider aliases. This ensures 
  providers = { helm = helm.jupyter, kubernetes = kubernetes.jupyter }

  # Important: This ensures JupyterHub is only deployed after the cluster is ready
  depends_on = [module.infrastructure, kubernetes_namespace.jupyter]

  # Basic settings
  project_id        = var.project_id
  namespace         = var.jupyter_namespace
  autopilot_cluster = var.autopilot_cluster

  # Auth settings - disabling IAP for custom JWT auth later
  add_auth      = false
  create_brand  = var.create_brand
  support_email = var.support_email

  # Storage settings
  gcs_bucket = google_storage_bucket.jupyter_bucket.name

  # Service account
  workload_identity_service_account = var.workload_identity_service_account

  # Default notebook image settings
  notebook_image     = var.notebook_image
  notebook_image_tag = var.notebook_image_tag

  # Resource settings
  ephemeral_storage = var.ephemeral_storage
}
