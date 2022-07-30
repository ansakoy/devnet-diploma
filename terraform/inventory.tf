resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      nat_ip_address = yandex_compute_instance.node-proxy.network_interface.0.nat_ip_address,
      ssh_key = yandex_compute_instance.node-proxy.metadata.ssh-keys,
      address_www = yandex_compute_instance.node-www.network_interface.0.ip_address,
      address_alertmanager = yandex_compute_instance.node-alertmanager.network_interface.0.ip_address,
      address_db01 = yandex_compute_instance.node-db01.network_interface.0.ip_address,
      address_db02 = yandex_compute_instance.node-db02.network_interface.0.ip_address,
      address_gitlab = yandex_compute_instance.node-gitlab.network_interface.0.ip_address,
      address_grafana = yandex_compute_instance.node-grafana.network_interface.0.ip_address,
      address_prometheus = yandex_compute_instance.node-prometheus.network_interface.0.ip_address,
      base_domain = var.domain,
      workspace = terraform.workspace,
      ssh_key_file = var.ssh_key_file,
      mysql_slave_user_pass = var.mysql_slave_user_pass,
      mysql_wp_user_pass = var.mysql_wp_user_pass,
      wp_auth_key = var.wp_auth_key,
      wp_secure_auth_key = var.wp_secure_auth_key,
      wp_logged_in_key = var.wp_logged_in_key,
      wp_nonce_key = var.wp_nonce_key,
      wp_auth_salt = var.wp_auth_salt,
      wp_secure_auth_salt = var.wp_secure_auth_salt,
      wp_logged_in_salt = var.wp_logged_in_salt,
      wp_nonce_salt = var.wp_nonce_salt,
    }
  )
  filename = "../ansible/inventory.ini"
  depends_on = [
    yandex_compute_instance.node-proxy,
    yandex_compute_instance.node-www,
    yandex_compute_instance.node-alertmanager,
    yandex_compute_instance.node-gitlab,
    yandex_compute_instance.node-grafana,
    yandex_compute_instance.node-prometheus,
    yandex_dns_recordset.rs-proxy,
    yandex_dns_recordset.rs-www,
    yandex_dns_recordset.rs-gitlab,
    yandex_dns_recordset.rs-grafana,
    yandex_dns_recordset.rs-prometheus,
    yandex_dns_recordset.rs-alertmanager,
  ]
}