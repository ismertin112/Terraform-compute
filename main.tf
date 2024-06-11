terraform{
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
            
        }
    }
}

provider "yandex" {
    zone = "ru-central1-a"

}

resource "yandex_compute_disk" "disk-1" {
  name = "disk-1"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = 20
  image_id = "fd89cudngj3s2osr228p"
}

resource "yandex_compute_disk" "disk-2" {
  name = "disk-2"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = 20
  image_id = "fd89cudngj3s2osr228p"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk-1.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

resource "yandex_compute_instance" "vm-2" {
  name = "terraform2"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk-2.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

resource "yandex_vpc_network" "network-testing" {
  name = "network-testing"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-testing"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-testing.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "internal_ip_address_vm_2" {
    value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
    value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}