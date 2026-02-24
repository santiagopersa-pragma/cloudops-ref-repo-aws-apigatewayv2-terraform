# Sample — WebSocket API Gateway

Ejemplo funcional del módulo `cloudops-ref-repo-aws-apigatewayv2-terraform`.

## Qué crea este ejemplo

- Dos Lambdas stub (Node.js 22.x):
  - `ws-connection`: maneja `$connect` y `$disconnect`
  - `ws-message`: maneja `$default` (todos los mensajes)
- WebSocket API Gateway con las tres rutas estándar
- CloudWatch Logs con 30 días de retención
- Rol IAM para las Lambdas con permisos básicos de ejecución

## Cómo ejecutarlo

```bash
cd sample/
terraform init
terraform plan
terraform apply
```

## Cómo probarlo

Una vez desplegado, el output `websocket_url` tendrá la URL `wss://...`.
Puedes conectarte con `wscat` (npm install -g wscat):

```bash
wscat -c wss://<api-id>.execute-api.us-east-1.amazonaws.com/dev
> {"action": "test", "message": "hola"}
```

## Cómo destruirlo

```bash
terraform destroy
```
