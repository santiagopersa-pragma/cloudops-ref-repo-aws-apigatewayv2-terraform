output "websocket_url" {
  description = "URL de conexión WebSocket. Úsala desde el cliente: new WebSocket('<url>')"
  value       = module.websocket.stage_invoke_url
}

output "api_id" {
  description = "ID de la API WebSocket"
  value       = module.websocket.api_id
}

output "cloudwatch_log_group" {
  description = "Nombre del log group de CloudWatch"
  value       = module.websocket.cloudwatch_log_group_name
}
