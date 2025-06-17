# Copyright 2025 Google LLC
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


locals {
  ingress_name        = var.k8s_ingress_name != "" ? var.k8s_ingress_name : "${var.app_name}-ingress"
  managed_cert_name   = var.k8s_managed_cert_name != "" ? var.k8s_managed_cert_name : "${var.app_name}-managed-cert"
  backend_config_name = var.k8s_backend_config_name != "" ? var.k8s_backend_config_name : "${var.app_name}-backend-config"

  iap_secret_name = var.k8s_iap_secret_name != "" ? var.k8s_iap_secret_name : "${var.app_name}-iap-secret"
}

module "iap" {
  source = "../iap"

  providers = {
    kubernetes = kubernetes.from_cluster_data
    helm       = helm.from_cluster_data
  }

  project_id               = var.project_id
  namespace                = var.namespace
  support_email            = var.support_email
  app_name                 = var.app_name
  create_brand             = var.create_brand
  k8s_ingress_name         = local.ingress_name
  k8s_managed_cert_name    = local.managed_cert_name
  k8s_iap_secret_name      = local.iap_secret_name
  k8s_backend_config_name  = local.backend_config_name
  k8s_backend_service_name = var.k8s_backend_service_name
  k8s_backend_service_port = var.k8s_backend_service_port
  client_id                = var.client_id
  client_secret            = var.client_secret
  domain                   = var.domain
  members_allowlist        = var.members_allowlist
}
