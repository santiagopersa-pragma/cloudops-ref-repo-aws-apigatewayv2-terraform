# El backend debe ser configurado en el módulo raíz, no aquí.
# Este módulo no define un backend propio.
#
# Ejemplo de configuración de backend S3 en el módulo raíz:
#
# terraform {
#   backend "s3" {
#     bucket = "mi-bucket-terraform-state"
#     key    = "proyecto/websocket/terraform.tfstate"
#     region = "us-east-1"
#   }
# }
#
# Referencia: https://developer.hashicorp.com/terraform/language/settings/backends/configuration