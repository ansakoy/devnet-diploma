# This file was autogenerated as a result of setting up a YC account

variable "yc_cloud_id" {
  type = string
  default = "b1gkltlcig08copnc8bc"
  description = "ID облака"
}

variable "yc_folder_id" {
  type = string
  default = "b1gjed8md31ldtt38dov"
  description = "ID каталога"
}

variable "yc_sa_account" {
  type = string
  default = "ajerk4goltnbscc54rko"
  description = "ID сервисного аккаунта"
}

variable "yc_sa_key_path" {
  type = string
  default = "/Users/ansakoy/Documents/Courses/netology/devnet-diploma/key.json"
  description = "Путь к ключу сервисного аккаунта"
}

variable "yc_zone_1a" {
  type = string
  default = "ru-central1-a"
  description = "Зона доступности A"
}

variable "yc_zone_1b" {
  type = string
  default = "ru-central1-b"
  description = "Зона доступности B"
}

variable "access_key_id" {
  type = string
  default = ""
  description = "Access key для бакета"
}

variable "access_key_secret" {
  type = string
  default = ""
  description = "Secret для access key бакета"
}

variable "domain" {
  type = string
  default = "catabasis.site"
  description = "Домен, на котором будут создаваться поддомены"
}

variable "ubuntu2004" {
  type = string
  default = "fd8f1tik9a7ap9ik2dg1"
  description = "Образ Убунту 20.04"
}

variable "ubuntu1804" {
  type = string
  default = "fd84mnpg35f7s7b0f5lg"
  description = "Образ Убунту 18.04"
}

variable "ssh_key_file" {
  type = string
  default = "~/.ssh/id_ed25519"
  description = "Ключ SSH"
}

variable "mysql_slave_user_pass" {
  type = string
  default = "replica123slave"
  description = "Пароль для реплики MySQL"
}

variable "mysql_wp_user_pass" {
  type = string
  default = "wordpress"
  description = "Пароль для юзера wordpress"
}

variable "wp_auth_key" {
  type = string
  default = "zZv9KZrwOA0temVZvKk-Y0YVEVQCWKj4zt4BCz-uWRy6Yr2AAM4DXA6xybPl2Ej3oRbmYOzk9OeIljqEZc3fvA"
  description = "Wordpress secret key"
}

variable "wp_secure_auth_key" {
  type = string
  default = "IZ_VAvpzWkio69hTzFPUuEvj7CZO8uvu4dHpq26H1m7dJtPv82CM-sLp9WlcolvvyTiFxbHmcEM8iH3t1auyCw"
  description = "Wordpress secret key"
}

variable "wp_logged_in_key" {
  type = string
  default = "b6VAt7chV25f63hWRycHT9FkBV1cZn-w6yuqR0H5kavfgr9GfdsMK2XbqPWWHg6zEDdx5T56upfnk6ZWHntAOA"
  description = "Wordpress secret key"
}

variable "wp_nonce_key" {
  type = string
  default = "5bNzUZ0BFRnoM1TziyLnOmiDmZ95odqa7upjm_K_DkBOBf1deML45ZBG8LNvam8ZR7mrByx0ZrNYPtMPlepTXg"
  description = "Wordpress secret key"
}

variable "wp_auth_salt" {
  type = string
  default = "qDlDr8zkXz-1VizuKDSrotijx9tD8t-TDp6lEbSgSfx_8TSXwnxZPO-jZewLumWN0V3LYfTfkxnvtny3LUUFbw"
  description = "Wordpress secret key"
}

variable "wp_secure_auth_salt" {
  type = string
  default = "bIJZ5fEKgGcSg-2MuGqn_QA7S4HHqiaNrjMa7MO6sB7PnLw1bSM7aqGkjDGvRety4IZKAM5ArL7o9LxLoztUGA"
  description = "Wordpress secret key"
}

variable "wp_logged_in_salt" {
  type = string
  default = "BGoTVYr-x6n7z-Hl37ZEoBBLwzJlbFUqBNTlsFziLN5t3qu_lR031A2RVr8migPII7yRIoKjcZuRVIJqxI_epQ"
  description = "Wordpress secret key"
}

variable "wp_nonce_salt" {
  type = string
  default = "HSI-rH8r4xyZ3XGHWRJ4IuRsCaroH8gKkChYvQE02gxCEFA9ULDAXZiDoZJhsBwrIcprfhQYCmCrGfW47v9Iyw"
  description = "Wordpress secret key"
}

