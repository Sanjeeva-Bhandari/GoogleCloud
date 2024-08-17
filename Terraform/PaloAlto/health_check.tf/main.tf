# Ref: This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# PaloAlto official doc: https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/deploy-vm-series-on-gcp
# PaloAlto official GitHub: https://github.com/PaloAltoNetworks/google-cloud-vmseries-ha-tutorial
# I have created below main.tf with respect to my requirement. It creates health check satisfying the paloalto rules as per its official doc June 2024
# Mostly with one health check you can work with the Loadbalancer 
# I have showned 2 health check creation one for external load balancer and another for internal load balancer
# before reunning below code check gcloud auth login and gcloud config set <project_name>
# add this code as main.tf in a directory -- cd to that directory and run below commands
# terraform init (terraform init -reconfigure = if you have already used any file which had backend.tf)
# terraform validate  = to check any syntax error
# terraform plan 
# terraform apply




resource "google_compute_health_check" "vmseries" {
  name                = "health check name"
  description         = "Health Check description"
  project             = "prj-name"
  #scope               = global
#region              = "region-name"
  check_interval_sec  = 5
  healthy_threshold   = 2
  timeout_sec         = 5
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_region_health_check" "vmseries" {
  name                = "health check name"
  description         = "Health Check description"
  project             = "prj-name"
  region              = "region-name"
  check_interval_sec  = 5
  healthy_threshold   = 2
  timeout_sec         = 5
  unhealthy_threshold = 2

  tcp_health_check {
    port         = 80
    #request_path = "/"
  }
}
