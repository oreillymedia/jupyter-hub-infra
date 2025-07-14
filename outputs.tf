output "project_id" {
  description = "The project ID where resources are deployed"
  value       = module.infrastructure.project_id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.infrastructure.cluster_name
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = module.infrastructure.cluster_location
}

output "endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.infrastructure.endpoint
  sensitive   = true
}

output "ca_certificate" {
  description = "The cluster CA certificate (base64 encoded)"
  value       = module.infrastructure.ca_certificate
  sensitive   = true
}

output "service_account" {
  description = "The service account used by the GKE cluster"
  value       = module.infrastructure.service_account
  sensitive   = true
}

output "private_cluster" {
  description = "Whether the GKE cluster is private"
  value       = module.infrastructure.private_cluster
}

# JupyterHub outputs
output "jupyterhub_user" {
  description = "The default admin username for JupyterHub"
  value       = module.jupyter.jupyterhub_user
}

output "jupyterhub_password" {
  description = "The password for the JupyterHub admin user"
  value       = module.jupyter.jupyterhub_password
  # Uncomment the line below if you want to hide the password from CLI output
  sensitive = true
}

output "jupyterhub_launcher_api_token" {
  description = "The admin token used to launch JupyterHub notebooks"
  value       = module.jupyter.jupyterhub_launcher_api_token
  # Uncomment the line below if you want to hide the password from CLI output
  sensitive = true
}

output "jupyterhub_uri" {
  description = "The URI for accessing JupyterHub (if using IAP)"
  value       = module.jupyter.jupyterhub_uri
}

output "jupyterhub_loadbalancer_ip" {
  description = "The IP address for accessing JupyterHub (if using IAP)"
  value       = module.jupyter.jupyterhub_ip_address
}

output "jupyter_bucket" {
  description = "The GCS bucket created for JupyterHub data"
  value       = google_storage_bucket.jupyter_bucket.name
}
