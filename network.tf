resource "yandex_vpc_network" "diplom" {
  name = "diplom-net"
}

resource "yandex_vpc_gateway" "nat" {
  name = "diplom-nat"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private" {
  name       = "diplom-private-rt"
  network_id = yandex_vpc_network.diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

resource "yandex_vpc_subnet" "public_a" {
  name           = "public-d2"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.41.0/24"]
}

resource "yandex_vpc_subnet" "public_b" {
  name           = "public-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.2.0/24"]
}

resource "yandex_vpc_subnet" "private_a" {
  name           = "private-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.11.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "private-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.12.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private_c" {
  name           = "private-a3"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.51.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "public_c" {
  name           = "public-a3"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["10.10.61.0/24"]
}
