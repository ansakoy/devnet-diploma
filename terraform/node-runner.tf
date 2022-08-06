resource "yandex_compute_instance" "node-runner" {
  name                      = "node-runner-${terraform.workspace}"
  zone                      = var.yc_zone_1b
  hostname                  = "runner.${var.domain}"
  description = "Машина для Gitlab runner"
  platform_id = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 8
    core_fraction = local.instance_fraction[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu2004  # Ставим заданную версию системы во избежание проблем с обновленными версиями
      name        = "root-node-runner"
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    ip_address = "192.168.100.18"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}