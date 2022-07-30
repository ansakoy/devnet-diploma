resource "yandex_compute_instance" "node-grafana" {
  name                      = "node-grafana-${terraform.workspace}"
  zone                      = var.yc_zone_1b
  hostname                  = "grafana.${var.domain}"
  description = "Машина для Grafana"
  platform_id = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
    core_fraction = local.instance_fraction[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu2004  # Ставим заданную версию системы во избежание проблем с обновленными версиями
      name        = "root-node-grafana"
      type        = "network-nvme"
      size        = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    ip_address = "192.168.100.16"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}