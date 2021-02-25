provider "google" {
  project = "kubespray-rccl"
  region  = "us-central1"
  zone    = "us-central1-c"
}

data "google_client_openid_userinfo" "me" {
    }

resource "google_os_login_ssh_public_key" "cache" {
    user =  data.google_client_openid_userinfo.me.email
    key = file("/home/kwan/.ssh/kubespray.pub")
}

resource "google_compute_instance" "vm_instance" {
  count = "3"
  name         = "vm-worker-${count.index + 1}"
  machine_type = "f1-micro"
  tags = ["kubespray-vm"]

  boot_disk {
    initialize_params {
      # image = "debian-cloud/debian-9"
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = google_compute_network.vpc_network.self_link
    access_config {
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "ssh-rule" {
  name = "allow-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  target_tags = ["kubespray-vm"]
  source_ranges = ["73.46.216.205/32"]
}
