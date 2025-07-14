# Project settings
project_id = "user-vvusmdhtcsmm"
region     = "us-central1"

# Network settings
create_network  = true
network_name    = "jupyterhub-network"
subnetwork_name = "jupyterhub-subnet"
# subnetwork_cidr = "10.100.0.0/16"

# Cluster settings
private_cluster                      = false
autopilot_cluster                    = true
cluster_name                         = "jupyterhub-cluster"
cluster_location                     = "us-central1"
kubernetes_version                   = "1.30"
release_channel                      = "REGULAR"
deletion_protection                  = false
gcs_fuse_csi_driver                  = true
ray_addon_enabled                    = false
monitoring_enable_managed_prometheus = true
load_balancer_source_ranges          = ["34.29.249.148/32", "199.27.145.253/32"] # Oreilly VPN

# JupyterHub settings
jupyter_namespace                 = "jupyter"
workload_identity_service_account = "jupyter-sa"
notebook_image                    = "jupyter/tensorflow-notebook" # default spawner image
notebook_image_tag                = "python-3.10"
ephemeral_storage                 = "5Gi"
create_brand                      = false
support_email                     = "admin@example.com" # placeholder email for required field. Not used.
