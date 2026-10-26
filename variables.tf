variable "cloud_id" {
  type        = string
  default     = null
  description = "ID облака, можно задать через YC_CLOUD_ID"
}

variable "folder_id" {
  type        = string
  default     = null
  description = "ID каталога, можно задать через YC_FOLDER_ID"
}

variable "sa_key_file" {
  type        = string
  default     = null
  description = "Путь к authorized key сервисного аккаунта; без него провайдер берёт YC_TOKEN"
}

variable "zone_a" {
  type    = string
  default = "ru-central1-d"
}

variable "zone_b" {
  type    = string
  default = "ru-central1-e"
}

variable "ssh_user" {
  type    = string
  default = "user"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "image_family" {
  type    = string
  default = "ubuntu-2204-lts"
}

variable "preemptible" {
  type        = bool
  default     = true
  description = "Перед сдачей на проверку поставить false, чтобы ВМ не выключались"
}

variable "snapshot_cron" {
  type        = string
  default     = "0 1 * * *"
  description = "Время ежедневного снимка, UTC"
}
