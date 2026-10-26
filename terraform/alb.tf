resource "yandex_alb_target_group" "web" {
  name = "web-tg"

  dynamic "target" {
    for_each = ["web-1", "web-2"]
    content {
      subnet_id  = yandex_compute_instance.vm[target.value].network_interface[0].subnet_id
      ip_address = yandex_compute_instance.vm[target.value].network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "web-bg"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web.id]

    load_balancing_config {
      panic_threshold = 90
    }

    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3
      healthcheck_port    = 80

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "web-host"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "root"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name               = "web-alb2"
  network_id         = yandex_vpc_network.diplom.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    location {
      zone_id   = var.zone_a
      subnet_id = yandex_vpc_subnet.public_a.id
    }
    location {
      zone_id   = var.zone_b
      subnet_id = yandex_vpc_subnet.public_b.id
    }
  }

  listener {
    name = "http"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}
