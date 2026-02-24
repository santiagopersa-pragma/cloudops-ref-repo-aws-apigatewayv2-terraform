# Changelog

Todos los cambios notables de este módulo se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-02-24

### Added
- `aws_apigatewayv2_api`: WebSocket API con `route_selection_expression` configurable
- `aws_apigatewayv2_stage`: Stage con `auto_deploy`, throttling y logging configurable
- `aws_apigatewayv2_integration`: Integraciones Lambda `AWS_PROXY` por ruta
- `aws_apigatewayv2_route`: Rutas configurables via mapa `var.routes`
- `aws_lambda_permission`: Permisos automáticos por cada ruta definida
- `aws_iam_role` + `aws_iam_role_policy`: Rol de menor privilegio para escritura en CloudWatch
- `aws_cloudwatch_log_group`: Logs con retención configurable y cifrado KMS opcional
- Variable `routes` como mapa configurable con soporte para `authorization_type` opcional
- Variable `data_trace_enabled` (default: `false`) para controlar exposición de datos en logs
- Variable `throttling_burst_limit` y `throttling_rate_limit` para protección de Lambdas
- Condición `aws:SourceAccount` en el rol IAM para prevenir "confused deputy"
- Sistema de etiquetado de 2 niveles (tags base + `additional_tags`)
- Nomenclatura estándar Pragma CloudOps: `{client}-{project}-{environment}-{type}-{key}`
- Directorio `sample/` con ejemplo funcional completo
- Documentación completa en README.md siguiendo estándar de módulos Pragma CloudOps
