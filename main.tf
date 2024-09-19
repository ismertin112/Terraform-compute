terraform {
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
  name     = "disk-1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = 20
  image_id = "fd89cudngj3s2osr228p"

  lifecycle {
    prevent_destroy = true
  }
}


resource "yandex_compute_disk" "disk-test" {
  name     = "disk-2"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
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

  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_compute_instance" "test-pks" {
  name = "test-pks"
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    disk_id = yandex_compute_disk.disk-test.id
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true

    security_group_ids = [yandex_vpc_security_group.group-test.id]

  }
  metadata = {
    user-data = "${file("./metadata.yml")}"
  }
}

resource "yandex_vpc_network" "network-testing" {
  name = "network-testing"

  lifecycle {
    prevent_destroy = true
  }
}

resource "yandex_vpc_security_group" "group-test" {
  name       = "test-group"
  network_id = yandex_vpc_network.network-testing.id

  ingress {
    description    = "ssh"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["46.191.181.120/32"]
  }
  ingress {
    description    = "test"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "internet"
    port           = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "ssh"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = ["46.191.181.120/32"]
  }
  egress {
    description    = "internet"
    port           = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "test"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-testing"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-testing.id
  v4_cidr_blocks = ["192.168.10.0/24"]

  lifecycle {
    prevent_destroy = true
  }
}
output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address

}


output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
output "external_ip_address_test_psks" {
  value = yandex_compute_instance.test-pks.network_interface.0.nat_ip_address

}
