# cloudops-ref-repo-aws-apigatewayv2-terraform

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-%3E%3D5.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 1. Descripción

Módulo de referencia IaC (Infrastructure as Code) con Terraform para el aprovisionamiento de **AWS API Gateway v2 WebSocket** en AWS, siguiendo las convenciones y estándares del equipo CloudOps de Pragma.

Este módulo permite crear y gestionar:

- **WebSocket API**: Canal de comunicación bidireccional en tiempo real entre clientes y backends Lambda.
- **Stage de despliegue**: Con auto-deploy, throttling configurable y logging integrado.
- **Rutas y integraciones**: Mapa configurable de rutas (`$connect`, `$disconnect`, `$default`, rutas personalizadas) conectadas a funciones Lambda.
- **Permisos Lambda**: `aws_lambda_permission` por cada ruta para que API Gateway pueda invocar las funciones.
- **Rol IAM**: Con políticas de menor privilegio para escritura en CloudWatch Logs.
- **CloudWatch Logs**: Grupo de logs para auditoría y monitoreo con cifrado KMS opcional.

### ¿Cuándo usar este módulo?

Úsalo cuando necesites comunicación en tiempo real full-duplex entre un cliente (navegador, app móvil) y un backend. Casos de uso típicos:

- Entrevistas conversacionales con IA (voz en tiempo real con Amazon Nova Sonic)
- Chats en tiempo real
- Notificaciones push bidireccionales
- Streaming de datos en tiempo real

## 2. Arquitectura

```
┌──────────────────────────────────────────────────────────────────────┐
│                            AWS Account                                │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │                  Módulo API Gateway v2 WebSocket              │    │
│  │                                                                │    │
│  │  ┌──────────────────────┐   ┌──────────────────────────────┐ │    │
│  │  │  WebSocket API        │   │  Stage                       │ │    │
│  │  │  ┌────────────────┐  │   │  ┌──────────────────────┐   │ │    │
│  │  │  │ $connect       │──┼───┼─►│  auto_deploy = true  │   │ │    │
│  │  │  │ $disconnect    │  │   │  │  throttling           │   │ │    │
│  │  │  │ $default       │  │   │  │  logging              │   │ │    │
│  │  │  │ custom routes  │  │   │  └──────────────────────┘   │ │    │
│  │  │  └────────────────┘  │   └──────────────────────────────┘ │    │
│  │  └──────────────────────┘                                     │    │
│  │                                                                │    │
│  │  ┌──────────────────────┐   ┌──────────────────────────────┐ │    │
│  │  │  Lambda Integrations  │   │  IAM                         │ │    │
│  │  │  (AWS_PROXY)          │   │  ┌──────────────────────┐   │ │    │
│  │  │  + Lambda Permissions │   │  │  Role (least priv.)  │   │ │    │
│  │  └──────────────────────┘   │  │  + CloudWatch Policy │   │ │    │
│  │                              │  └──────────────────────┘   │ │    │
│  │                              └──────────────────────────────┘ │    │
│  │                                                                │    │
│  │  ┌──────────────────────────────────────────────────────┐    │    │
│  │  │  CloudWatch Logs                                      │    │    │
│  │  │  /aws/apigateway/ws/{client}-{project}-{env}-{name}  │    │    │
│  │  │  Retención configurable + cifrado KMS opcional        │    │    │
│  │  └──────────────────────────────────────────────────────┘    │    │
│  └──────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

## 3. Pre-requisitos

- **Terraform** >= 1.0
- **AWS Provider** >= 5.0
- **AWS CLI** configurado con credenciales válidas
- **Funciones Lambda** ya creadas (el módulo solo crea los permisos, no las Lambdas)
- **Permisos IAM** para crear:
  - `apigateway:*` sobre el API Gateway
  - `iam:CreateRole`, `iam:PutRolePolicy`, `iam:AttachRolePolicy`
  - `lambda:AddPermission`
  - `logs:CreateLogGroup`
- (Opcional) **pre-commit** para validación automática local
- (Opcional) **terraform-docs** para generación automática de documentación

## 4. Convenciones de Nomenclatura

Todos los recursos siguen el patrón estándar de Pragma CloudOps:

```
{client}-{project}-{environment}-{type}-{key}
```

| Recurso | Ejemplo de nombre |
|---|---|
| WebSocket API | `pragma-ia-eva-dev-apigw-ws-conversational` |
| Stage | stage name configurable (default: `prod`) |
| IAM Role | `pragma-ia-eva-dev-apigw-ws-role` |
| Log Group | `/aws/apigateway/ws/pragma-ia-eva-dev-conversational` |

## 5. Estructura del Módulo

```
cloudops-ref-repo-aws-apigatewayv2-terraform/
├── main.tf                   # Recursos: API, Stage, Routes, Integrations, IAM, CloudWatch
├── variables.tf              # Variables con validaciones
├── outputs.tf                # Outputs descriptivos
├── locals.tf                 # Transformaciones de nomenclatura y tags
├── data.tf                   # Data sources (account, region, partition)
├── providers.tf              # Nota sobre configuración del provider
├── versions.tf               # Versiones de Terraform y providers
├── backend.tf                # Nota sobre configuración del backend
├── tags.tf                   # Documentación del sistema de etiquetado
├── README.md                 # Esta documentación
├── CHANGELOG.md              # Historial de cambios (Keep a Changelog)
├── .gitignore                # Exclusiones de Git
├── .terraform-docs.yml       # Configuración de terraform-docs
├── .pre-commit-config.yaml   # Hooks de pre-commit
└── sample/                   # Ejemplo funcional completo
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── README.md
```

## 6. Uso

### Uso básico — tres rutas estándar

```hcl
module "websocket" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-apigatewayv2-terraform.git?ref=v1.0.0"

  client      = "pragma"
  project     = "mi-proyecto"
  environment = "dev"

  routes = {
    connect = {
      route_key            = "$connect"
      lambda_invoke_arn    = aws_lambda_function.connect.invoke_arn
      lambda_function_name = aws_lambda_function.connect.function_name
    }
    disconnect = {
      route_key            = "$connect"
      lambda_invoke_arn    = aws_lambda_function.disconnect.invoke_arn
      lambda_function_name = aws_lambda_function.disconnect.function_name
    }
    default = {
      route_key            = "$default"
      lambda_invoke_arn    = aws_lambda_function.message.invoke_arn
      lambda_function_name = aws_lambda_function.message.function_name
    }
  }
}
```

### Uso avanzado — con configuración completa

```hcl
module "websocket" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-apigatewayv2-terraform.git?ref=v1.0.0"

  client      = "pragma"
  project     = "ia-eva"
  environment = "pdn"

  api_name_suffix            = "conversational"
  stage_name                 = "pdn"
  route_selection_expression = "$request.body.action"

  routes = {
    connect = {
      route_key            = "$connect"
      lambda_invoke_arn    = aws_lambda_function.ws_connect.invoke_arn
      lambda_function_name = aws_lambda_function.ws_connect.function_name
      authorization_type   = "NONE"
    }
    disconnect = {
      route_key            = "$disconnect"
      lambda_invoke_arn    = aws_lambda_function.ws_disconnect.invoke_arn
      lambda_function_name = aws_lambda_function.ws_disconnect.function_name
      authorization_type   = "NONE"
    }
    message = {
      route_key            = "$default"
      lambda_invoke_arn    = aws_lambda_function.ws_message.invoke_arn
      lambda_function_name = aws_lambda_function.ws_message.function_name
      authorization_type   = "NONE"
    }
  }

  throttling_burst_limit = 200
  throttling_rate_limit  = 100
  data_trace_enabled     = false

  enable_cloudwatch_logging     = true
  cloudwatch_log_retention_days = 365
  cloudwatch_kms_key_arn        = aws_kms_key.logs.arn

  additional_tags = {
    Purpose    = "conversational-ai"
    AI_Models  = "nova-sonic"
    CostCenter = "4813150000"
  }
}

# Usar el invoke URL en la Lambda o en el frontend
output "websocket_url" {
  value = module.websocket.stage_invoke_url
  # Ejemplo: wss://abc123.execute-api.us-east-1.amazonaws.com/pdn
}
```

### Con módulo referenciado localmente (durante desarrollo)

```hcl
module "websocket" {
  source = "../../../cloudops-ref-repo-aws-apigatewayv2-terraform"

  client      = "pragma"
  project     = "ia-eva"
  environment = "dev"

  routes = { ... }
}
```

## 7. Variables

| Variable | Tipo | Requerida | Default | Descripción |
|---|---|---|---|---|
| `client` | `string` | ✅ | - | Nombre del cliente (máx. 20 chars) |
| `project` | `string` | ✅ | - | Nombre del proyecto (máx. 30 chars) |
| `environment` | `string` | ✅ | - | Ambiente: `dev`, `stg`, `qa`, `pdn`, `sandbox` |
| `api_name_suffix` | `string` | No | `"main"` | Sufijo para el nombre de la API |
| `stage_name` | `string` | No | `"prod"` | Nombre del stage |
| `route_selection_expression` | `string` | No | `"$request.body.action"` | Expresión de selección de ruta |
| `routes` | `map(object)` | No | `{}` | Mapa de rutas y sus Lambdas |
| `throttling_burst_limit` | `number` | No | `100` | Burst máximo de solicitudes concurrentes |
| `throttling_rate_limit` | `number` | No | `50` | Rate máximo de solicitudes por segundo |
| `enable_cloudwatch_logging` | `bool` | No | `true` | Habilitar logging en CloudWatch |
| `cloudwatch_log_retention_days` | `number` | No | `90` | Días de retención de logs |
| `cloudwatch_kms_key_arn` | `string` | No | `null` | ARN KMS para cifrado de logs |
| `data_trace_enabled` | `bool` | No | `false` | Rastreo completo de request/response |
| `additional_tags` | `map(string)` | No | `{}` | Tags adicionales |

### Estructura de `routes`

```hcl
routes = {
  key = {
    route_key            = string            # "$connect", "$disconnect", "$default" o personalizada
    lambda_invoke_arn    = string            # Invoke ARN de la Lambda (requerido)
    lambda_function_name = string            # Nombre de la función Lambda (requerido)
    authorization_type   = optional(string)  # "NONE" (default) o "AWS_IAM"
  }
}
```

## 8. Outputs

| Output | Descripción |
|---|---|
| `api_id` | ID de la API WebSocket |
| `api_arn` | ARN de la API WebSocket |
| `api_endpoint` | Endpoint base (wss://...) |
| `execution_arn` | ARN de ejecución para permisos Lambda |
| `stage_id` | ID del stage |
| `stage_invoke_url` | URL completa de conexión (wss://.../stage) |
| `cloudwatch_log_group_name` | Nombre del log group |
| `cloudwatch_log_group_arn` | ARN del log group |
| `iam_role_arn` | ARN del rol IAM |
| `iam_role_name` | Nombre del rol IAM |
| `name_prefix` | Prefijo de nomenclatura usado |
| `route_ids` | Mapa de IDs de rutas creadas |
| `integration_ids` | Mapa de IDs de integraciones creadas |

## 9. Seguridad

Este módulo implementa las siguientes prácticas de seguridad:

- **Principio de menor privilegio**: El rol IAM solo permite escritura en el log group específico creado por el módulo, no en todos los recursos de CloudWatch.
- **Condición SourceAccount**: El rol IAM incluye `aws:SourceAccount` para prevenir el problema del "confused deputy".
- **`data_trace_enabled` deshabilitado por defecto**: Evita que request/response completos (que pueden contener audio o datos sensibles) se registren en producción.
- **Throttling habilitado por defecto**: Protege las Lambdas de picos de tráfico no esperados.
- **Cifrado KMS opcional**: Soporte para cifrado de logs de CloudWatch con clave KMS propia.
- **Tags de trazabilidad**: Todos los recursos incluyen `Client`, `Project`, `Environment` y `ManagedBy`.

## 10. Ejemplo Funcional

El directorio `sample/` contiene un ejemplo completamente funcional. Para ejecutarlo:

```bash
cd sample/
terraform init
terraform plan
terraform apply
```

Consultar [sample/README.md](sample/README.md) para más detalles.

## 11. Versionamiento

Este módulo sigue [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR**: Cambios incompatibles (breaking changes)
- **MINOR**: Nuevas funcionalidades compatibles hacia atrás
- **PATCH**: Correcciones de errores compatibles hacia atrás

Consultar [CHANGELOG.md](CHANGELOG.md) para el historial completo de cambios.

## 12. Autores y Contribución

**Equipo CloudOps - Pragma SA**

Para contribuir:

1. Crear un branch desde `main`: `feature/mi-mejora`
2. Implementar los cambios siguiendo las [reglas IaC de Pragma CloudOps](https://github.com/somospragma/cloudops-ref-repo-mcp-iac-rules)
3. Validar con el servidor MCP IaC Rules
4. Actualizar `CHANGELOG.md`
5. Crear un Pull Request hacia `main`

---

<!-- BEGIN_TF_DOCS -->
*Ejecutar `terraform-docs markdown table .` para generar documentación automática.*
<!-- END_TF_DOCS -->
