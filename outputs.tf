###########################################
################# API #####################
###########################################

output "api_id" {
  description = "ID de la API WebSocket."
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "ARN de la API WebSocket."
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "Endpoint de la API WebSocket (wss://). Usar para establecer la conexión desde el cliente."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "ARN de ejecución de la API. Usado para configurar permisos de Lambda (source_arn)."
  value       = aws_apigatewayv2_api.this.execution_arn
}

###########################################
################ Stage ####################
###########################################

output "stage_id" {
  description = "ID del stage de despliegue."
  value       = aws_apigatewayv2_stage.this.id
}

output "stage_invoke_url" {
  description = "URL de invocación del stage (wss://.../stage_name). URL completa para conectarse desde el cliente."
  value       = aws_apigatewayv2_stage.this.invoke_url
}

###########################################
############# CloudWatch ##################
###########################################

output "cloudwatch_log_group_name" {
  description = "Nombre del log group de CloudWatch. Null si logging está deshabilitado."
  value       = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.this[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN del log group de CloudWatch. Null si logging está deshabilitado."
  value       = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.this[0].arn : null
}

###########################################
################ IAM ######################
###########################################

output "iam_role_arn" {
  description = "ARN del rol IAM para escritura en CloudWatch. Null si logging está deshabilitado."
  value       = var.enable_cloudwatch_logging ? aws_iam_role.cloudwatch[0].arn : null
}

output "iam_role_name" {
  description = "Nombre del rol IAM para escritura en CloudWatch. Null si logging está deshabilitado."
  value       = var.enable_cloudwatch_logging ? aws_iam_role.cloudwatch[0].name : null
}

###########################################
############# Nomenclatura ################
###########################################

output "name_prefix" {
  description = "Prefijo de nomenclatura utilizado en todos los recursos: {client}-{project}-{environment}."
  value       = local.name_prefix
}

output "route_ids" {
  description = "Mapa de IDs de rutas creadas. Clave: nombre del mapa de routes. Valor: ID de la ruta."
  value       = { for k, v in aws_apigatewayv2_route.this : k => v.id }
}

output "integration_ids" {
  description = "Mapa de IDs de integraciones Lambda creadas. Clave: nombre del mapa de routes."
  value       = { for k, v in aws_apigatewayv2_integration.this : k => v.id }
}