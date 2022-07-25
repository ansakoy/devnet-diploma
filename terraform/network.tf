resource "yandex_vpc_network" "diploma-vpc-network" {
  name = "vpc-net-a"
}

resource "yandex_vpc_subnet" "subnet-a" {  # Допустим, эта у нас будет публичной
  name = "vpc-subnet-a"
  zone = var.yc_zone_1a
  network_id  = yandex_vpc_network.diploma-vpc-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-b" {
  name = "vpc-subnet-b"
  zone  = var.yc_zone_1b
  network_id  = yandex_vpc_network.diploma-vpc-network.id
  v4_cidr_blocks = ["192.168.100.0/24"]
}