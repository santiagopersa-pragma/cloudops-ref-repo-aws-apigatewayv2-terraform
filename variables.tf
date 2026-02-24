###########################################
########### Required Variables ############
###########################################

variable "client" {
  type        = string
  description = "Nombre del cliente. Usado en el prefijo de nomenclatura de todos los recursos."
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 20
    error_message = "client no puede estar vacío y debe tener máximo 20 caracteres."
  }
}

variable "project" {
  type        = string
  description = "Nombre del proyecto. Usado en el prefijo de nomenclatura de todos los recursos."
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 30
    error_message = "project no puede estar vacío y debe tener máximo 30 caracteres."
  }
}

variable "environment" {
  type        = string
  description = "Ambiente de despliegue. Valores permitidos: dev, stg, qa, pdn, sandbox."
  validation {
    condition     = contains(["dev", "stg", "qa", "pdn", "sandbox"], var.environment)
    error_message = "environment debe ser uno de: dev, stg, qa, pdn, sandbox."
  }
}

###########################################
########### API Configuration #############
###########################################

variable "api_name_suffix" {
  type        = string
  description = "Sufijo para el nombre de la API WebSocket. Permite crear múltiples APIs en el mismo proyecto."
  default     = "main"
  validation {
    condition     = length(var.api_name_suffix) > 0 && length(var.api_name_suffix) <= 30
    error_message = "api_name_suffix no puede estar vacío y debe tener máximo 30 caracteres."
  }
}

variable "stage_name" {
  type        = string
  description = "Nombre del stage de despliegue."
  default     = "prod"
}

variable "route_selection_expression" {
  type        = string
  description = "Expresión para seleccionar la ruta según el mensaje recibido. Por defecto usa el campo 'action' del body."
  default     = "$request.body.action"
}

###########################################
################ Routes ###################
###########################################

variable "routes" {
  type = map(object({
    route_key            = string
    lambda_invoke_arn    = string
    lambda_function_name = string
    authorization_type   = optional(string, "NONE")
  }))
  description = <<-EOT
    Mapa de rutas WebSocket. Cada entrada define una ruta y su integración Lambda.
    Claves típicas: connect ($connect), disconnect ($disconnect), default ($default).

    Ejemplo:
    routes = {
      connect = {
        route_key            = "$connect"
        lambda_invoke_arn    = "arn:aws:lambda:..."
        lambda_function_name = "mi-funcion"
        authorization_type   = "NONE"
      }
    }
  EOT
  default = {}
}

###########################################
############# Throttling ##################
###########################################

variable "throttling_burst_limit" {
  type        = number
  description = "Número máximo de solicitudes concurrentes permitidas (burst). Protege las Lambdas de picos de tráfico."
  default     = 100
  validation {
    condition     = var.throttling_burst_limit >= 0
    error_message = "throttling_burst_limit debe ser mayor o igual a 0."
  }
}

variable "throttling_rate_limit" {
  type        = number
  description = "Número máximo de solicitudes por segundo (rate). Aplica de forma sostenida."
  default     = 50
  validation {
    condition     = var.throttling_rate_limit >= 0
    error_message = "throttling_rate_limit debe ser mayor o igual a 0."
  }
}

###########################################
########### CloudWatch Logging ############
###########################################

variable "enable_cloudwatch_logging" {
  type        = bool
  description = "Habilita el registro de acceso en CloudWatch Logs. Recomendado en todos los ambientes."
  default     = true
}

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "Días de retención de los logs en CloudWatch."
  default     = 90
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_retention_days)
    error_message = "cloudwatch_log_retention_days debe ser un período válido de CloudWatch: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827 o 3653."
  }
}

variable "cloudwatch_kms_key_arn" {
  type        = string
  description = "ARN de la clave KMS para cifrar los logs de CloudWatch. Si es null, se usa cifrado por defecto de AWS."
  default     = null
}

variable "data_trace_enabled" {
  type        = bool
  description = "Habilita el rastreo completo de datos (request/response). PRECAUCIÓN: puede exponer datos sensibles. No recomendado en producción."
  default     = false
}

###########################################
################ Tags #####################
###########################################

variable "additional_tags" {
  type        = map(string)
  description = "Tags adicionales que se aplicarán a todos los recursos del módulo."
  default     = {}
}