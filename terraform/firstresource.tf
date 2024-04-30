resource "yandex_compute_disk" "boot_disk" {
  name     = "srv-minik"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd80bm0rh4rkepi5ksdi"
  size     = 50
  labels = {
    environment = "test"
  }
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  resources {
    cores  = 8
    memory = 16
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk.id
  }


  #  boot_disk {
  #    initialize_params {
  #      disk_id = yandex_compute_disk.boot_disk.id
  #    }
  #  }

  network_interface {
    subnet_id = yandex_vpc_subnet.asubnet.id
    nat       = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: darklu\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("~/.ssh/key-terr.pub")}"
  }
}


resource "yandex_vpc_network" "anet" {
  name = "anet"
}

resource "yandex_vpc_subnet" "asubnet" {
  name           = "asubnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.anet.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface[0].ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface[0].nat_ip_address
}
