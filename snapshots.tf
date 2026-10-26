resource "yandex_compute_snapshot_schedule" "daily" {
  name             = "daily-7d"
  retention_period = "168h0m0s"

  schedule_policy {
    expression = var.snapshot_cron
  }

  snapshot_spec {
    description = "daily snapshot"
  }

  disk_ids = [for vm in yandex_compute_instance.vm : vm.boot_disk[0].disk_id]
}
