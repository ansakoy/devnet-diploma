resource "yandex_compute_instance" "node-proxy" {
  name                      = "node-proxy-${terraform.workspace}"
  zone                      = var.yc_zone_1a
  hostname                  = var.domain
  description = "Прокси с публичным IP"
  platform_id = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
    core_fraction = local.instance_fraction[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu1804  # Ставим версию системы, пригодную для nat-инстанса
      name        = "root-node-proxy"
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat       = true
    ip_address = "192.168.10.12"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
