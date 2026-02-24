# Sistema de etiquetado de 2 niveles — Pragma CloudOps
#
# Nivel 1: Tags base obligatorias (definidas en locals.tf)
#   - Client:      nombre del cliente
#   - Project:     nombre del proyecto
#   - Environment: ambiente (dev/stg/qa/pdn/sandbox)
#   - ManagedBy:   "terraform"
#   - Module:      nombre del módulo
#
# Nivel 2: Tags adicionales por recurso
#   Todos los recursos usan `tags = local.tags`.
#   Para tags específicas de un recurso en particular, usar merge():
#
#   tags = merge(local.tags, {
#     Purpose = "websocket-audio-streaming"
#   })
#
# Tags adicionales del proyecto se pasan via var.additional_tags y quedan
# incorporadas en local.tags automáticamente.
