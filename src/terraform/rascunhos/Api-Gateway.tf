resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "api-gateway-easyorder"
}

# Autorizador - Cognito
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  name        = "cognito_authorizer"
  type        = "COGNITO_USER_POOLS"
  provider_arns = [
    aws_cognito_user_pool.easyorder_admin_pool.arn
  ]
}

# Endpoints de Cliente
resource "aws_api_gateway_resource" "endpoints_cliente" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "cliente"
}

# /cliente/cadastrar - sem autenticação
resource "aws_api_gateway_resource" "cliente_cadastrar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.endpoints_cliente.id
  path_part   = "cadastrar"
}
resource "aws_api_gateway_method" "cliente_cadastrar" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.cliente_cadastrar.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "cliente_cadastrar_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cliente_cadastrar.id
  http_method = aws_api_gateway_method.cliente_cadastrar.http_method
  type        = "MOCK"
}

# /cliente/atualizar - sem autenticação
resource "aws_api_gateway_resource" "cliente_atualizar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.endpoints_cliente.id
  path_part   = "atualizar"
}
resource "aws_api_gateway_method" "cliente_atualizar" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.cliente_atualizar.id
  http_method   = "PUT"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "cliente_atualizar_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cliente_atualizar.id
  http_method = aws_api_gateway_method.cliente_atualizar.http_method
  type        = "MOCK"
}

# /cliente/listar - com autenticação Cognito
resource "aws_api_gateway_resource" "cliente_listar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.endpoints_cliente.id
  path_part   = "listar"
}
resource "aws_api_gateway_method" "cliente_listar" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.cliente_listar.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}
resource "aws_api_gateway_integration" "cliente_listar_integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.cliente_listar.id
  http_method = aws_api_gateway_method.cliente_listar.http_method
  type        = "MOCK" # Altere para LAMBDA ou HTTP conforme necessário
}

# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  depends_on = [
    aws_api_gateway_method.cliente_cadastrar,
    aws_api_gateway_integration.cliente_cadastrar_integration,
    aws_api_gateway_method.cliente_atualizar,
    aws_api_gateway_integration.cliente_atualizar_integration,
    aws_api_gateway_method.cliente_listar,
    aws_api_gateway_integration.cliente_listar_integration
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "prod"
}

# Outputs
output "rest_api_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
}

output "rest_api_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}
