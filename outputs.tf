locals {
  pub  = { for k, vm in yandex_compute_instance.vm : k => vm.network_interface[0].nat_ip_address }
  fqdn = { for k, vm in yandex_compute_instance.vm : k => vm.fqdn }
}

resource "local_file" "inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.ini"
  file_permission = "0644"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    user       = var.ssh_user
    bastion_ip = local.pub["bastion"]
    fqdn       = local.fqdn
  })
}

output "bastion_ip" {
  value = local.pub["bastion"]
}

output "site_url" {
  value = "http://${yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}/"
}

output "zabbix_url" {
  value = "http://${local.pub["zabbix"]}/"
}

output "kibana_url" {
  value = "http://${local.pub["kibana"]}:5601/"
}

output "fqdn" {
  value = local.fqdn
}

output "ssh_bastion" {
  value = "ssh -J ${var.ssh_user}@${local.pub["bastion"]} ${var.ssh_user}@web-1.ru-central1.internal"
}
