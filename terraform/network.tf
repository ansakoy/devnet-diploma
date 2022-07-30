resource "yandex_vpc_network" "diploma-vpc-network" {
  name = "vpc-net-a"
}

resource "yandex_vpc_subnet" "subnet-a" {  # Допустим, эта у нас будет публичной
  name = "vpc-subnet-a"
  zone = var.yc_zone_1a
  network_id  = yandex_vpc_network.diploma-vpc-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Таблица маршрутизации
resource "yandex_vpc_route_table" "nat-instance" {
  name = "nat-instance-route"
  network_id = yandex_vpc_network.diploma-vpc-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.12"
  }
}

resource "yandex_vpc_subnet" "subnet-b" {
  name = "vpc-subnet-b"
  zone  = var.yc_zone_1b
  network_id  = yandex_vpc_network.diploma-vpc-network.id
  route_table_id = yandex_vpc_route_table.nat-instance.id
  v4_cidr_blocks = ["192.168.100.0/24"]
}
