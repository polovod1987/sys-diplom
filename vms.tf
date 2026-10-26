data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

data "yandex_compute_image" "debian11" {
  family = "debian-11"
}

data "yandex_compute_image" "debian12" {
  family = "debian-12"
}

locals {
  images = {
    ubuntu   = data.yandex_compute_image.ubuntu.id
    debian11 = data.yandex_compute_image.debian11.id
    debian12 = data.yandex_compute_image.debian12.id
  }

  ssh_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  vms = {
    bastion = {
      subnet = yandex_vpc_subnet.public_b
      nat    = true
      memory = 2
      disk   = 8
      dtype  = "network-ssd"
      sgs    = [yandex_vpc_security_group.bastion.id]
    }
    web-1 = {
      image  = "debian12"
      subnet = yandex_vpc_subnet.private_a
      nat    = false
      memory = 2
      disk   = 5
      dtype  = "network-hdd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.web.id]
    }
    web-2 = {
      subnet = yandex_vpc_subnet.private_b
      nat    = false
      memory = 2
      disk   = 8
      dtype  = "network-hdd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.web.id]
    }
    db-primary = {
      subnet = yandex_vpc_subnet.private_a
      nat    = false
      memory = 2
      disk   = 8
      dtype  = "network-ssd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.db.id]
    }
    elastic = {
      subnet = yandex_vpc_subnet.private_a
      nat    = false
      memory = 4
      disk   = 8
      dtype  = "network-hdd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.elastic.id]
    }
    kibana = {
      subnet = yandex_vpc_subnet.public_b
      nat    = true
      memory = 4
      disk   = 8
      dtype  = "network-hdd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.kibana.id]
    }
    zabbix = {
      image  = "debian12"
      subnet = yandex_vpc_subnet.public_a
      nat    = true
      memory = 2
      disk   = 5
      dtype  = "network-hdd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.zabbix.id]
    }
    db-secondary = {
      image  = "debian11"
      subnet = yandex_vpc_subnet.private_b
      nat    = false
      memory = 2
      disk   = 4
      dtype  = "network-hdd"
      sgs    = [yandex_vpc_security_group.internal.id, yandex_vpc_security_group.db.id]
    }
  }
}

resource "yandex_compute_instance" "vm" {
  for_each = local.vms

  name        = each.key
  hostname    = each.key
  zone        = each.value.subnet.zone
  platform_id = "standard-v3"

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [boot_disk[0].initialize_params[0].image_id]
  }

  timeouts {
    create = "40m"
  }

  resources {
    cores         = 2
    core_fraction = 20
    memory        = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = local.images[lookup(each.value, "image", "ubuntu")]
      type     = each.value.dtype
      size     = each.value.disk
    }
  }

  network_interface {
    subnet_id          = each.value.subnet.id
    nat                = each.value.nat
    security_group_ids = each.value.sgs
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = {
    user-data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
      user    = var.ssh_user
      ssh_key = local.ssh_key
    })
    serial-port-enable = 0
  }
}
