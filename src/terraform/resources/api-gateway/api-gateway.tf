terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
}

resource "aws_api_gateway_rest_api" "api-gateway-easyorder" {
  name = "api-gateway-easyorder"
}

# Autorizador - Autenticação Cognito
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  name        = "cognito_authorizer"
  type        = "COGNITO_USER_POOLS"
  provider_arns = [
    "arn:aws:cognito-idp:us-east-1:123456789012:userpool/us-east-1_example" # Substitua pelo ARN do seu user pool
  ]
}

# Autorizador - Lambda Clientes
resource "aws_lambda_function" "auth_lambda" {
  filename         = "auth_lambda.zip" # Substitua pelo arquivo da função Lambda
  function_name    = "auth_lambda_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  name        = "lambda_authorizer"
  type        = "TOKEN"
  authorizer_uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.auth_lambda.arn}/invocations"
}

# endpoints de Cliente
resource "aws_api_gateway_resource" "endpoints-cliente" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "cliente"
}

# Exemplo de endpoint com autenticação Cognito
resource "aws_api_gateway_method" "listar_clientes" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.cliente.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Exemplo de endpoint com Lambda Auth
resource "aws_api_gateway_method" "auth_cliente" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.cliente.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id
}

# Exemplo de endpoint sem autenticação
resource "aws_api_gateway_method" "cadastrar_cliente" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.cliente.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrations
resource "aws_api_gateway_integration" "listar_clientes_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.cliente.id
  http_method = aws_api_gateway_method.listar_clientes.http_method
  type        = "MOCK" # Altere para LAMBDA ou HTTP conforme necessário
}

resource "aws_api_gateway_integration" "auth_cliente_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.cliente.id
  http_method = aws_api_gateway_method.auth_cliente.http_method
  type        = "AWS_PROXY"
  uri         = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.auth_lambda.arn}/invocations"
}

resource "aws_api_gateway_integration" "cadastrar_cliente_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.cliente.id
  http_method = aws_api_gateway_method.cadastrar_cliente.http_method
  type        = "MOCK"
}

# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "prod"
}

# Outputs
output "rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}

output "rest_api_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
