resource "yandex_vpc_security_group" "bastion" {
  name       = "sg-bastion"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "SSH from internet"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "internal" {
  name       = "sg-internal"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "SSH only from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb" {
  name       = "sg-alb"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "HTTP from internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "ALB node health checks"
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "sg-web"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "HTTP from ALB"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb.id
  }

  ingress {
    description       = "Backend health checks"
    protocol          = "TCP"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

}

resource "yandex_vpc_security_group" "zabbix" {
  name       = "sg-zabbix"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "Zabbix web UI"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Active agents"
    protocol          = "TCP"
    port              = 10051
    security_group_id = yandex_vpc_security_group.internal.id
  }

  ingress {
    description       = "Active agent on bastion"
    protocol          = "TCP"
    port              = 10051
    security_group_id = yandex_vpc_security_group.bastion.id
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "sg-kibana"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description    = "Kibana web UI"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elastic" {
  name       = "sg-elastic"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "Filebeat from web"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    description       = "Kibana"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
  }
}

resource "yandex_vpc_security_group" "db" {
  name       = "sg-db"
  network_id = yandex_vpc_network.diplom.id

  ingress {
    description       = "Zabbix server"
    protocol          = "TCP"
    port              = 5432
    security_group_id = yandex_vpc_security_group.zabbix.id
  }

  ingress {
    description       = "Replication between db nodes"
    protocol          = "TCP"
    port              = 5432
    predefined_target = "self_security_group"
  }
}
