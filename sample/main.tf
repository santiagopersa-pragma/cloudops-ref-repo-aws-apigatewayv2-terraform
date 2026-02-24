###############################################################################
# Ejemplo funcional: WebSocket API Gateway con dos Lambdas stub
#
# Este ejemplo crea:
#   - Una Lambda stub para manejar $connect / $disconnect
#   - Una Lambda stub para manejar mensajes ($default)
#   - El módulo WebSocket API Gateway con las tres rutas estándar
#   - CloudWatch Logs habilitado
###############################################################################

provider "aws" {
  region = var.aws_region
}

###############################################################################
# IAM Role para las Lambdas stub
###############################################################################

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.client}-${var.project}-${var.environment}-sample-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###############################################################################
# Lambda stub: connection handler ($connect / $disconnect)
###############################################################################

data "archive_file" "connection_handler" {
  type        = "zip"
  output_path = "${path.module}/connection_handler.zip"

  source {
    content  = <<-EOF
      exports.handler = async (event) => {
        console.log('Event:', JSON.stringify(event));
        return { statusCode: 200, body: 'OK' };
      };
    EOF
    filename = "index.js"
  }
}

resource "aws_lambda_function" "connection_handler" {
  function_name    = "${var.client}-${var.project}-${var.environment}-ws-connection"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.connection_handler.output_path
  source_code_hash = data.archive_file.connection_handler.output_base64sha256
}

###############################################################################
# Lambda stub: message handler ($default)
###############################################################################

data "archive_file" "message_handler" {
  type        = "zip"
  output_path = "${path.module}/message_handler.zip"

  source {
    content  = <<-EOF
      exports.handler = async (event) => {
        console.log('Message event:', JSON.stringify(event));
        return { statusCode: 200, body: 'Message received' };
      };
    EOF
    filename = "index.js"
  }
}

resource "aws_lambda_function" "message_handler" {
  function_name    = "${var.client}-${var.project}-${var.environment}-ws-message"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.message_handler.output_path
  source_code_hash = data.archive_file.message_handler.output_base64sha256
}

###############################################################################
# Módulo WebSocket API Gateway
###############################################################################

module "websocket" {
  source = "../"

  client      = var.client
  project     = var.project
  environment = var.environment

  api_name_suffix = "sample"
  stage_name      = var.environment

  routes = {
    connect = {
      route_key            = "$connect"
      lambda_invoke_arn    = aws_lambda_function.connection_handler.invoke_arn
      lambda_function_name = aws_lambda_function.connection_handler.function_name
    }
    disconnect = {
      route_key            = "$disconnect"
      lambda_invoke_arn    = aws_lambda_function.connection_handler.invoke_arn
      lambda_function_name = aws_lambda_function.connection_handler.function_name
    }
    default = {
      route_key            = "$default"
      lambda_invoke_arn    = aws_lambda_function.message_handler.invoke_arn
      lambda_function_name = aws_lambda_function.message_handler.function_name
    }
  }

  enable_cloudwatch_logging     = true
  cloudwatch_log_retention_days = 30
  throttling_burst_limit        = 50
  throttling_rate_limit         = 25

  additional_tags = {
    Purpose = "sample-websocket"
  }
}
