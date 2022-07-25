resource "yandex_dns_zone" "public-zone" {
  name        = "diploma-public-zone"
  description = "Public zone"
  folder_id   = var.yc_folder_id
  zone    = "${var.domain}."
  public  = true

  labels = {
    label1 = "diploma-public"
  }
}

resource "yandex_dns_recordset" "rs-proxy" {
  depends_on = [yandex_compute_instance.node-proxy]
  zone_id = yandex_dns_zone.public-zone.id
  name    = "${var.domain}."
  type    = "A"
  ttl     = 30
  data    = [yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs-www" {
  zone_id = yandex_dns_zone.public-zone.id
  name    = "www"
  type    = "A"
  ttl     = 30
  data    = [yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address]
  depends_on = [yandex_compute_instance.node-proxy]
}

resource "yandex_dns_recordset" "rs-gitlab" {
  depends_on = [yandex_compute_instance.node-proxy]
  zone_id = yandex_dns_zone.public-zone.id
  name    = "gitlab"
  type    = "A"
  ttl     = 30
  data    = [yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs-grafana" {
  depends_on = [yandex_compute_instance.node-proxy]
  zone_id = yandex_dns_zone.public-zone.id
  name    = "grafana"
  type    = "A"
  ttl     = 30
  data    = [yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs-prometheus" {
  depends_on = [yandex_compute_instance.node-proxy]
  zone_id = yandex_dns_zone.public-zone.id
  name    = "prometheus"
  type    = "A"
  ttl     = 30
  data    = [yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs-alertmanager" {
  depends_on = [yandex_compute_instance.node-proxy]
  zone_id = yandex_dns_zone.public-zone.id
  name    = "alertmanager"
  type    = "A"
  ttl     = 30
  data    = [yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address]
}
