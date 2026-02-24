###########################################
########## WebSocket API Gateway ##########
###########################################

resource "aws_apigatewayv2_api" "this" {
  name                       = "${local.name_prefix}-apigw-ws-${var.api_name_suffix}"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = var.route_selection_expression

  tags = local.tags
}

###########################################
############ CloudWatch Logs ##############
###########################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.enable_cloudwatch_logging ? 1 : 0

  name              = "/aws/apigateway/ws/${local.name_prefix}-${var.api_name_suffix}"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = var.cloudwatch_kms_key_arn

  tags = local.tags
}

###########################################
######### IAM - CloudWatch Role ###########
###########################################

resource "aws_iam_role" "cloudwatch" {
  count = var.enable_cloudwatch_logging ? 1 : 0

  name = "${local.name_prefix}-apigw-ws-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "cloudwatch" {
  count = var.enable_cloudwatch_logging ? 1 : 0

  name = "${local.name_prefix}-apigw-ws-policy"
  role = aws_iam_role.cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
      Resource = [
        aws_cloudwatch_log_group.this[0].arn,
        "${aws_cloudwatch_log_group.this[0].arn}:*"
      ]
    }]
  })
}

###########################################
################# Stage ###################
###########################################

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
    data_trace_enabled     = var.data_trace_enabled
    logging_level          = var.enable_cloudwatch_logging ? "INFO" : "OFF"
  }

  dynamic "access_log_settings" {
    for_each = var.enable_cloudwatch_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.this[0].arn
    }
  }

  tags = local.tags
}

###########################################
######### Integrations & Routes ###########
###########################################

resource "aws_apigatewayv2_integration" "this" {
  for_each = var.routes

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "AWS_PROXY"
  integration_uri    = each.value.lambda_invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"

  authorization_type = try(each.value.authorization_type, "NONE")
}

###########################################
######### Lambda Permissions ##############
###########################################

resource "aws_lambda_permission" "this" {
  for_each = var.routes

  statement_id  = "AllowWebSocketInvoke-${replace(replace(each.value.route_key, "$", ""), "/", "-")}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}