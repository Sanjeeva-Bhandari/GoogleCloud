# Ref links
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
# https://cloud.google.com/docs/terraform/create-vm-instance 
# A simple way of creating VM instance with below code 
# one can also get similar results while selecting all the necessary parameter on console and at the end of console rather than clicking on Create click on Equivalant code and select terraform in it
# before reunning below code check gcloud auth login and gcloud config set <project_name>
# add this code as main.tf in a directory -- cd to that directory and run below commands
# terraform init (terraform init -reconfigure = if you have already used any file which had backend.tf)
# terraform validate  = to check any syntax error
# terraform plan 
# terraform apply


resource "google_compute_instance" "instance" {          // put your choice of object name in place of  "instance"
  
  boot_disk {
    auto_delete = true
    device_name = "device_name"   // put your device name this will be the name of disk

    initialize_params {
      image = "image"             //put image path either google clouds public image or image path from google cloud marketplace
      size  = "size"              // put boot disk size in GB   
      type  = "pd-balanced"      // disk type as pd-balanced change according to your requirement
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false          // to prevent data loss keep it false since it allows an instance to send and receive packets with non-matching destination or source IPs
  deletion_protection = true          // deletion protection best practice to keep it true
  enable_display      = false         // virtual display need by any application but you dont want to add a GPU then make this true

  machine_type = "machine_type"      // put your choice of machine type here

  name         = "name"           //this will be the name of your instance you can keep instance and device name same

  network_interface {
    subnetwork = "subnetwork"     // put your subnetworks path here usually start from   project/
  }

  scheduling {
    automatic_restart   = true            // to allow vm instance to auto restart 
    on_host_maintenance = "MIGRATE"      // https://cloud.google.com/compute/docs/instances/setting-vm-host-options#available_host_maintenance_properties
    preemptible         = false          // its used in can of batch processing tasks so after batch processing Compute engine will stope these instances
    provisioning_model  = "STANDARD"     // determine vm pricing and uptime gurentee
  }

  service_account {
    email  = "email"                    // put your service account's whole email id
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }    // for example This allows the VM's service account to call the Google Cloud APIs that it has permission to use.

  shielded_instance_config {
    enable_integrity_monitoring = true   //if you are using local ssd then change this to false 
    enable_secure_boot          = true   //Secure Boot helps protect your VM instances against boot-level and kernel-level malware and root-kits
    enable_vtpm                 = true   //Its a  specialized computer chip you can use to protect objects, like keys and certificates, that you use to authenticate access to your system
  }

  tags = ["http-server", "https-server"]  
  zone = "zone"                         // zone in which your vm will be created

  labels = "labels"                    // add labels here
}

