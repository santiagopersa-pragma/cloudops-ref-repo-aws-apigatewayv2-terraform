# El provider AWS debe ser configurado en el módulo raíz, no aquí.
# Este módulo hereda la configuración del provider del módulo raíz.
#
# Ejemplo de configuración en el módulo raíz:
#
# provider "aws" {
#   region = "us-east-1"
# }
#
# Referencia: https://developer.hashicorp.com/terraform/language/modules/develop/providers