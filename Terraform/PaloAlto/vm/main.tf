# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration
# PaloAlto official doc: https://docs.paloaltonetworks.com/vm-series/9-1/vm-series-deployment/set-up-the-vm-series-firewall-on-google-cloud-platform/deploy-vm-series-on-gcp
# PaloAlto official GitHub: https://github.com/PaloAltoNetworks/google-cloud-vmseries-ha-tutorial
# I have created below main.tf with respect to my requirement. It creates server satisfying all the paloalto rules as per its official doc June 2024
# image path for gcp marketplace : image = "projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1102"
# After this craetion one has to create unmanaged instance group (UIG) for instance (e.g if creating one PaloAlto insance then 1 unmanged instance group having the same instance.
# In case of multiple PaloAlto vm create multiple UIG having single PaloAlto instace in it.
# We can add multiple backend to our loadbalancer.

resource "google_compute_instance" "instance" {      # put instance resource name as per your need

  boot_disk {
    auto_delete = true
    device_name = "device_name"                    # put device name as per your need
    initialize_params {
      image = "var.image"                          # put image path of paloalto vmseries 
      size  = "var.size"                          # put size of boot disk
      type  = "pd-balanced"                      # put boot disk type as per your need     
    }

    mode = "READ_WRITE"
  }
  


  can_ip_forward      = true                    # enable can_ip_forward
  deletion_protection = true                    # enable deletion_protection comes under best practice
  enable_display      = false

  // Adding METADATA Key Value pairs to VM-Series GCE instance
  metadata = {
    ssh-keys = "var.public_key"                 # Put your public ssh key
  } 

  mgmt-interface-swap = "enable"                # most important parameter for PaloAlto deployment this must be enable otherwise PaloAlto won't work -- this will make untrust as nic0

  machine_type = "var.machine_type"            # put your desired machine type

  name         = "var.name"                    # put name of your choice

  network_interface {
    subnetwork = "subnet-untrust"              # Put your untrust subnet path
 
    #access_config {
    #  nat_ip = "put your ip"              leave this as it is it'll create nat_ip automatically ---or if you already have one then put your nat_ip
    #} 
  }

  network_interface {
    subnetwork = "subnet-mgmt"                # put mgmt subnet path 
    
  }

  network_interface {
    subnetwork = "subnet-trust"                # put trust subnet path
  }

  network_interface {
    subnetwork = "subnet-trust1"              # if you are doing with multiple trust put trust1 subnet path otherwise comment it out
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "var.email"                   # Put your service account's email id
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }


  tags = ["http-server", "https-server"]
  zone = "var.zone"                       # put zone name in which you wanted to deploy PaloAlto server 

  labels = "var.labels"                   # add your label here
}
