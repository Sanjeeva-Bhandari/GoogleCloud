# Ref: This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# PaloAlto official doc: https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/deploy-vm-series-on-gcp
# PaloAlto official GitHub: https://github.com/PaloAltoNetworks/google-cloud-vmseries-ha-tutorial
# I have created below main.tf with respect to my requirement. It creates internal and external loadbalancers satisfying the paloalto rules as per its official doc June 2024
# Mostly with one health check (internal health check) you can work with the Loadbalancer 
# I have showned both internal and external loadbalancer creation with forwarding rules in this main.tf
# before reunning below code check gcloud auth login and gcloud config set <project_name>
# add this code as main.tf in a directory -- cd to that directory and run below commands
# terraform init (terraform init -reconfigure = if you have already used any file which had backend.tf)
# terraform validate  = to check any syntax error
# terraform plan 
# terraform apply





# ----------------------------------------------------------------------------------------------------------------
# Create an internal load balancer to distribute traffic to VM-Series trust interfaces.
# ----------------------------------------------------------------------------------------------------------------

resource "google_compute_forwarding_rule" "intlb" {
  name                  = "forwarding-rule-1-name"
  load_balancing_scheme = "INTERNAL"
  ip_address            = cidrhost("<enter-cidr-range-of-your-network>", 10)
  ip_protocol           = "TCP"
  all_ports             = true
  subnetwork            = "subnetwork path or trust vpc"
  allow_global_access   = true
  backend_service       = google_compute_region_backend_service.intlb.self_link
}

resource "google_compute_region_backend_service" "intlb" {
  provider         = google-beta
  name             = "name of your internal loadbalancer"
  region           = "region-name"
  health_checks    = ["internal-health-check-full-path"]
  network          = "vpc network link"
  session_affinity = null

  backend {
    group = "intance group link path "
    
  }

  backend {
     group = "another instance group link path if you are using 2 vm of paloalto"
}

  connection_tracking_policy {
    tracking_mode                                = "PER_SESSION"
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
    idle_timeout_sec                             = 600
  }
}






# ----------------------------------------------------------------------------------------------------------------
# Create an external load balancer to distribute traffic to VM-Series trust interfaces.
# ----------------------------------------------------------------------------------------------------------------

provider "google" {
  project = "prj-cds-commonhost"
  region = "europe-west3"
}


resource "google_compute_address" "external_nat_ip" {
  name         = "nlb-ip-name"
  region       = "region-name"
  address_type = "EXTERNAL"
}

resource "google_compute_forwarding_rule" "rule" {
  name                  = "forwarding rule name "
  project               = "prj-name"
  region                = "region-name"
  load_balancing_scheme = "EXTERNAL"
  all_ports             = true
  ip_address            = google_compute_address.external_nat_ip.address
  ip_protocol           = "TCP"
  backend_service       = google_compute_region_backend_service.extlb.self_link
}

resource "google_compute_region_backend_service" "extlb" {
  provider              = google-beta
  name                  = "external-loadbalancer-name"
  project               = "prj-name"
  region                = "region-name"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = ["internal-health-check-path"]
  protocol              = "TCP"

  backend {
    group = "intance group link path"
    
  }

  backend {
     group = "another instance group link path if you are using 2 vm of paloalto"
}

  connection_tracking_policy {
    tracking_mode                                = "PER_SESSION"
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
 }
}
