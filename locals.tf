###########################################
############ Nomenclatura #################
###########################################
# Patrón estándar Pragma CloudOps:
# {client}-{project}-{environment}-{type}-{key}
###########################################

locals {
  name_prefix = "${var.client}-${var.project}-${var.environment}"

  # Sistema de etiquetado de 2 niveles:
  # Nivel 1: Tags base obligatorias (trazabilidad, auditoría, costos)
  # Nivel 2: Tags adicionales por recurso via var.additional_tags
  tags = merge(
    {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "cloudops-ref-repo-aws-apigatewayv2-terraform"
    },
    var.additional_tags
  )
}