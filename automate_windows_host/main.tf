terraform {
  required_providers {
    virtualbox = {
      source = "shekeriev/virtualbox"
      version = "0.0.4"
    }
  }
}

provider "virtualbox" {
  delay      = 60
  mintimeout = 10
}

resource "virtualbox_vm" "casestudy" {
  name = "Windows-Ansible-VM"
  image ="./packer_virtualbox-iso_virtualbox.box"
  cpus = 2
  memory = "2048 mib"

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}

output "IPAddress" {
  value = element(virtualbox_vm.casestudy.*.network_adapter.0.ipv4_address, 1)
}