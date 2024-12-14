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

# GET / - Recurso raiz já existente - adicionando somente o método
resource "aws_api_gateway_method" "root_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "root_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_rest_api.api_gateway.root_resource_id
  http_method             = aws_api_gateway_method.root_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/backend-root" # Substitua pelo URL real
  integration_http_method = "GET"
}

# /health - Recurso
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "health"
}
# Método GET para /health
resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "health_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/health" # Substitua pelo URL real
  integration_http_method = "GET"
}

# /docs - Recurso
resource "aws_api_gateway_resource" "docs" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "docs"
}
# Método GET para /docs
resource "aws_api_gateway_method" "docs_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.docs.id
  http_method   = "GET"
  authorization = "NONE"
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "docs_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.docs.id
  http_method             = aws_api_gateway_method.docs_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/docs" # Substitua pelo URL real
  integration_http_method = "GET"
}


# /cliente - recurso pai
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
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.cliente_cadastrar.id
  http_method             = aws_api_gateway_method.cliente_cadastrar.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/cliente-cadastrar" # Altere para o URL real
  integration_http_method = "POST"
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
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.cliente_atualizar.id
  http_method             = aws_api_gateway_method.cliente_atualizar.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/cliente-atualizar" # Altere para o URL real
  integration_http_method = "PUT"
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
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.cliente_listar.id
  http_method             = aws_api_gateway_method.cliente_listar.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/cliente-listar" # Altere para o URL real
  integration_http_method = "GET"
}

# /cliente/auth/{cpf} - sem autenticação, integração com Lambda
# resource "aws_api_gateway_resource" "cliente_auth" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
#   parent_id   = aws_api_gateway_resource.endpoints_cliente.id
#   path_part   = "auth"
# }
# resource "aws_api_gateway_resource" "cliente_auth_cpf" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway.id
#   parent_id   = aws_api_gateway_resource.cliente_auth.id
#   path_part   = "{cpf}"
# }
# resource "aws_api_gateway_method" "cliente_auth_cpf" {
#   rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
#   resource_id   = aws_api_gateway_resource.cliente_auth_cpf.id
#   http_method   = "GET"
#   authorization = "NONE"
# }
# resource "aws_api_gateway_integration" "cliente_auth_cpf_integration" {
#   rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
#   resource_id             = aws_api_gateway_resource.cliente_auth_cpf.id
#   http_method             = aws_api_gateway_method.cliente_auth_cpf.http_method
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.cliente_auth_lambda.invoke_arn # adicionar o arn do lambda
#   integration_http_method = "GET" # Lambda integrations typically use POST
# }

# /pagamento/ - recurso pai
resource "aws_api_gateway_resource" "pagamento" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "pagamento"
}
# /pagamento/webhook/ - recurso
resource "aws_api_gateway_resource" "pagamento_webhook" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pagamento.id
  path_part   = "webhook"
}
# Método POST para /pagamento/webhook/ sem autenticação
resource "aws_api_gateway_method" "pagamento_webhook_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pagamento_webhook.id
  http_method   = "POST"
  authorization = "NONE"
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pagamento_webhook_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pagamento_webhook.id
  http_method             = aws_api_gateway_method.pagamento_webhook_post.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/backend-webhook-endpoint" # Substitua pelo URL real
  integration_http_method = "POST"
}



# /pagamento/listar-transacoes/ - recurso pai
resource "aws_api_gateway_resource" "pagamento_listar_transacoes" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pagamento.id
  path_part   = "listar-transacoes"
}
# /pagamento/listar-transacoes/{pedidoId} - recurso dinâmico
resource "aws_api_gateway_resource" "pagamento_listar_transacoes_pedidoId" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pagamento_listar_transacoes.id
  path_part   = "{pedidoId}"
}
# Método GET para /pagamento/listar-transacoes/{pedidoId} com autenticação Cognito
resource "aws_api_gateway_method" "pagamento_listar_transacoes_pedidoId" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pagamento_listar_transacoes_pedidoId.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pagamento_listar_transacoes_pedidoId_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pagamento_listar_transacoes_pedidoId.id
  http_method             = aws_api_gateway_method.pagamento_listar_transacoes_pedidoId.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/backend-endpoint/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "GET"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /pedido - Recurso pai
resource "aws_api_gateway_resource" "pedido" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "pedido"
}
# Método POST para /pedido
resource "aws_api_gateway_method" "pedido_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido.id
  http_method   = "POST"
  authorization = "NONE"
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido.id
  http_method             = aws_api_gateway_method.pedido_post.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-endpoint" # Substitua pelo URL real
  integration_http_method = "POST"
}

# /pedido/listar - Recurso intermediário
resource "aws_api_gateway_resource" "pedido_listar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido.id
  path_part   = "listar"
}
# /pedido/listar/{statusPedido} - Recurso dinâmico
resource "aws_api_gateway_resource" "pedido_listar_statusPedido" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido_listar.id
  path_part   = "{statusPedido}"
}
# Método GET para /pedido/listar/{statusPedido} com autenticação Cognito
resource "aws_api_gateway_method" "pedido_listar_statusPedido_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_listar_statusPedido.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.statusPedido" = true # Requer o parâmetro statusPedido
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_listar_statusPedido_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_listar_statusPedido.id
  http_method             = aws_api_gateway_method.pedido_listar_statusPedido_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-listar-endpoint/{statusPedido}" # Substitua pelo URL real
  integration_http_method = "GET"
  request_parameters = {
    "integration.request.path.statusPedido" = "method.request.path.statusPedido"
  }
}


# /pedido/{pedidoId} - Recurso dinâmico
resource "aws_api_gateway_resource" "pedido_pedidoId" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido.id
  path_part   = "{pedidoId}"
}
# Método GET para /pedido/{pedidoId} com autenticação Cognito
resource "aws_api_gateway_method" "pedido_pedidoId_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_pedidoId.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_pedidoId_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_pedidoId.id
  http_method             = aws_api_gateway_method.pedido_pedidoId_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-endpoint/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "GET"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /pedido/{pedidoId}/cancelar - Recurso
resource "aws_api_gateway_resource" "pedido_pedidoId_cancelar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido_pedidoId.id
  path_part   = "cancelar"
}
# Método PUT para /pedido/{pedidoId}/cancelar com autenticação Cognito
resource "aws_api_gateway_method" "pedido_pedidoId_cancelar_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_pedidoId_cancelar.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_pedidoId_cancelar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_pedidoId_cancelar.id
  http_method             = aws_api_gateway_method.pedido_pedidoId_cancelar_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-cancelar-endpoint/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /pedido/{pedidoId}/confirmacao-pagamento - Recurso
resource "aws_api_gateway_resource" "pedido_pedidoId_confirmacao_pagamento" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido_pedidoId.id
  path_part   = "confirmacao-pagamento"
}
# Método PUT para /pedido/{pedidoId}/confirmacao-pagamento sem autenticação
resource "aws_api_gateway_method" "pedido_pedidoId_confirmacao_pagamento_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_pedidoId_confirmacao_pagamento.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_pedidoId_confirmacao_pagamento_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_pedidoId_confirmacao_pagamento.id
  http_method             = aws_api_gateway_method.pedido_pedidoId_confirmacao_pagamento_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-confirmacao-pagamento-endpoint/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /pedido/{pedidoId}/checkout - Recurso
resource "aws_api_gateway_resource" "pedido_pedidoId_checkout" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido_pedidoId.id
  path_part   = "checkout"
}
# Método PUT para /pedido/{pedidoId}/checkout sem autenticação
resource "aws_api_gateway_method" "pedido_pedidoId_checkout_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_pedidoId_checkout.id
  http_method   = "PUT"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_pedidoId_checkout_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_pedidoId_checkout.id
  http_method             = aws_api_gateway_method.pedido_pedidoId_checkout_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-checkout-endpoint/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /pedido/{pedidoId}/combo - Recurso
resource "aws_api_gateway_resource" "pedido_pedidoId_combo" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido_pedidoId.id
  path_part   = "combo"
}
# Método POST para /pedido/{pedidoId}/combo sem autenticação
resource "aws_api_gateway_method" "pedido_pedidoId_combo_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_pedidoId_combo.id
  http_method   = "POST"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_pedidoId_combo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_pedidoId_combo.id
  http_method             = aws_api_gateway_method.pedido_pedidoId_combo_post.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-combo-endpoint/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "POST"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /pedido/{pedidoId}/combo/{comboId} - Recurso
resource "aws_api_gateway_resource" "pedido_pedidoId_combo_comboId" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.pedido_pedidoId_combo.id
  path_part   = "{comboId}"
}
# Método DELETE para /pedido/{pedidoId}/combo/{comboId} sem autenticação
resource "aws_api_gateway_method" "pedido_pedidoId_combo_comboId_delete" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.pedido_pedidoId_combo_comboId.id
  http_method   = "DELETE"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.pedidoId" = true # Requer o parâmetro pedidoId
    "method.request.path.comboId"  = true # Requer o parâmetro comboId
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "pedido_pedidoId_combo_comboId_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.pedido_pedidoId_combo_comboId.id
  http_method             = aws_api_gateway_method.pedido_pedidoId_combo_comboId_delete.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/pedido-combo-endpoint/{pedidoId}/{comboId}" # Substitua pelo URL real
  integration_http_method = "DELETE"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
    "integration.request.path.comboId"  = "method.request.path.comboId"
  }
}

# /preparacao - Recurso pai
resource "aws_api_gateway_resource" "preparacao" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "preparacao"
}
# /preparacao/pedido - Recurso intermediário
resource "aws_api_gateway_resource" "preparacao_pedido" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.preparacao.id
  path_part   = "pedido"
}

# /preparacao/pedido/proximo - Recurso final
resource "aws_api_gateway_resource" "preparacao_pedido_proximo" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.preparacao_pedido.id
  path_part   = "proximo"
}
# Método GET para /preparacao/pedido/proximo com autenticação Cognito
resource "aws_api_gateway_method" "preparacao_pedido_proximo_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.preparacao_pedido_proximo.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "preparacao_pedido_proximo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.preparacao_pedido_proximo.id
  http_method             = aws_api_gateway_method.preparacao_pedido_proximo_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/preparacao-pedido-proximo-endpoint" # Substitua pelo URL real
  integration_http_method = "GET"
}

# /preparacao/pedido/{pedidoId} - Recurso dinâmico
resource "aws_api_gateway_resource" "preparacao_pedido_pedidoId" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.preparacao_pedido.id
  path_part   = "{pedidoId}"
}
# /preparacao/pedido/{pedidoId}/iniciar-preparacao - Recurso final
resource "aws_api_gateway_resource" "preparacao_pedido_pedidoId_iniciar_preparacao" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.preparacao_pedido_pedidoId.id
  path_part   = "iniciar-preparacao"
}
# Método PUT para /preparacao/pedido/{pedidoId}/iniciar-preparacao com autenticação Cognito
resource "aws_api_gateway_method" "preparacao_pedido_pedidoId_iniciar_preparacao_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.preparacao_pedido_pedidoId_iniciar_preparacao.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pedidoId" = true
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "preparacao_pedido_pedidoId_iniciar_preparacao_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.preparacao_pedido_pedidoId_iniciar_preparacao.id
  http_method             = aws_api_gateway_method.preparacao_pedido_pedidoId_iniciar_preparacao_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/preparacao-pedido-iniciar-preparacao/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /preparacao/pedido/{pedidoId}/finalizar-preparacao - Recurso final
resource "aws_api_gateway_resource" "preparacao_pedido_pedidoId_finalizar_preparacao" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.preparacao_pedido_pedidoId.id
  path_part   = "finalizar-preparacao"
}
# Método PUT para /preparacao/pedido/{pedidoId}/finalizar-preparacao com autenticação Cognito
resource "aws_api_gateway_method" "preparacao_pedido_pedidoId_finalizar_preparacao_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.preparacao_pedido_pedidoId_finalizar_preparacao.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pedidoId" = true
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "preparacao_pedido_pedidoId_finalizar_preparacao_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.preparacao_pedido_pedidoId_finalizar_preparacao.id
  http_method             = aws_api_gateway_method.preparacao_pedido_pedidoId_finalizar_preparacao_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/preparacao-pedido-finalizar-preparacao/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /preparacao/pedido/{pedidoId}/entregar - Recurso final
resource "aws_api_gateway_resource" "preparacao_pedido_pedidoId_entregar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.preparacao_pedido_pedidoId.id
  path_part   = "entregar"
}
# Método PUT para /preparacao/pedido/{pedidoId}/entregar com autenticação Cognito
resource "aws_api_gateway_method" "preparacao_pedido_pedidoId_entregar_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.preparacao_pedido_pedidoId_entregar.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.pedidoId" = true
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "preparacao_pedido_pedidoId_entregar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.preparacao_pedido_pedidoId_entregar.id
  http_method             = aws_api_gateway_method.preparacao_pedido_pedidoId_entregar_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/preparacao-pedido-entregar/{pedidoId}" # Substitua pelo URL real
  integration_http_method = "PUT"
  request_parameters = {
    "integration.request.path.pedidoId" = "method.request.path.pedidoId"
  }
}

# /produto - Recurso pai
resource "aws_api_gateway_resource" "produto" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "produto"
}
# /produto/listar - Recurso final
resource "aws_api_gateway_resource" "produto_listar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto.id
  path_part   = "listar"
}
# Método GET para /produto/listar com autenticação Cognito
resource "aws_api_gateway_method" "produto_listar_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.produto_listar.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "produto_listar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.produto_listar.id
  http_method             = aws_api_gateway_method.produto_listar_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/produto-listar-endpoint" # Substitua pelo URL real
  integration_http_method = "GET"
}

# /produto/buscar - Recurso intermediário
resource "aws_api_gateway_resource" "produto_buscar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto.id
  path_part   = "buscar"
}
# /produto/buscar/{id} - Recurso dinâmico
resource "aws_api_gateway_resource" "produto_buscar_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto_buscar.id
  path_part   = "{id}"
}
# Método GET para /produto/buscar/{id} com autenticação Cognito
resource "aws_api_gateway_method" "produto_buscar_id_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.produto_buscar_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.id" = true # Requer o parâmetro id
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "produto_buscar_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.produto_buscar_id.id
  http_method             = aws_api_gateway_method.produto_buscar_id_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/produto-buscar-endpoint/{id}" # Substitua pelo URL real
  integration_http_method = "GET"
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}

# /produto/listar/{categoria} - Recurso dinâmico
resource "aws_api_gateway_resource" "produto_listar_categoria" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto_listar.id
  path_part   = "{categoria}"
}
# Método GET para /produto/listar/{categoria} com autenticação Cognito
resource "aws_api_gateway_method" "produto_listar_categoria_get" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.produto_listar_categoria.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.categoria" = true # Requer o parâmetro categoria
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "produto_listar_categoria_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.produto_listar_categoria.id
  http_method             = aws_api_gateway_method.produto_listar_categoria_get.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/produto-listar-endpoint/{categoria}" # Substitua pelo URL real
  integration_http_method = "GET"
  request_parameters = {
    "integration.request.path.categoria" = "method.request.path.categoria"
  }
}

# /produto/remover - Recurso intermediário
resource "aws_api_gateway_resource" "produto_remover" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto.id
  path_part   = "remover"
}
# /produto/remover/{id} - Recurso dinâmico
resource "aws_api_gateway_resource" "produto_remover_id" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto_remover.id
  path_part   = "{id}"
}
# Método DELETE para /produto/remover/{id} com autenticação Cognito
resource "aws_api_gateway_method" "produto_remover_id_delete" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.produto_remover_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.id" = true # Requer o parâmetro id
  }
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "produto_remover_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.produto_remover_id.id
  http_method             = aws_api_gateway_method.produto_remover_id_delete.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/produto-remover-endpoint/{id}" # Substitua pelo URL real
  integration_http_method = "DELETE"
  request_parameters = {
    "integration.request.path.id" = "method.request.path.id"
  }
}


# /produto/cadastrar - Recurso
resource "aws_api_gateway_resource" "produto_cadastrar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto.id
  path_part   = "cadastrar"
}
# Método POST para /produto/cadastrar com autenticação Cognito
resource "aws_api_gateway_method" "produto_cadastrar_post" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.produto_cadastrar.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "produto_cadastrar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.produto_cadastrar.id
  http_method             = aws_api_gateway_method.produto_cadastrar_post.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/produto-cadastrar-endpoint" # Substitua pelo URL real
  integration_http_method = "POST"
}

# /produto/atualizar - Recurso
resource "aws_api_gateway_resource" "produto_atualizar" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.produto.id
  path_part   = "atualizar"
}
# Método PUT para /produto/atualizar com autenticação Cognito
resource "aws_api_gateway_method" "produto_atualizar_put" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.produto_atualizar.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}
# Integração HTTP para o backend real
resource "aws_api_gateway_integration" "produto_atualizar_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.produto_atualizar.id
  http_method             = aws_api_gateway_method.produto_atualizar_put.http_method
  type                    = "HTTP_PROXY"
  uri                     = "https://example.com/produto-atualizar-endpoint" # Substitua pelo URL real
  integration_http_method = "PUT"
}

# Deployment
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  # Certifique-se de que o deployment dependa de todos os métodos e integrações
  depends_on = [
    # Métodos e integrações na raiz
    aws_api_gateway_method.root_get,
    aws_api_gateway_integration.root_get_integration,
    aws_api_gateway_method.health_get,
    aws_api_gateway_integration.health_get_integration,
    aws_api_gateway_method.docs_get,
    aws_api_gateway_integration.docs_get_integration,

    # Métodos e integrações de clientes
    aws_api_gateway_method.cliente_cadastrar,
    aws_api_gateway_integration.cliente_cadastrar_integration,
    aws_api_gateway_method.cliente_atualizar,
    aws_api_gateway_integration.cliente_atualizar_integration,
    aws_api_gateway_method.cliente_listar,
    aws_api_gateway_integration.cliente_listar_integration,
    #aws_api_gateway_method.cliente_auth_cpf, # Descomente quando configurado
    # aws_api_gateway_integration.cliente_auth_cpf_integration, # Descomente quando configurado

    # Métodos e integrações de pagamentos
    aws_api_gateway_method.pagamento_webhook_post,
    aws_api_gateway_integration.pagamento_webhook_integration,
    aws_api_gateway_method.pagamento_listar_transacoes_pedidoId,
    aws_api_gateway_integration.pagamento_listar_transacoes_pedidoId_integration,

    # Métodos e integrações de pedidos
    aws_api_gateway_method.pedido_post,
    aws_api_gateway_integration.pedido_post_integration,
    aws_api_gateway_method.pedido_listar_statusPedido_get,
    aws_api_gateway_integration.pedido_listar_statusPedido_integration,
    aws_api_gateway_method.pedido_pedidoId_get,
    aws_api_gateway_integration.pedido_pedidoId_integration,
    aws_api_gateway_method.pedido_pedidoId_cancelar_put,
    aws_api_gateway_integration.pedido_pedidoId_cancelar_integration,
    aws_api_gateway_method.pedido_pedidoId_confirmacao_pagamento_put,
    aws_api_gateway_integration.pedido_pedidoId_confirmacao_pagamento_integration,
    aws_api_gateway_method.pedido_pedidoId_checkout_put,
    aws_api_gateway_integration.pedido_pedidoId_checkout_integration,
    aws_api_gateway_method.pedido_pedidoId_combo_post,
    aws_api_gateway_integration.pedido_pedidoId_combo_integration,
    aws_api_gateway_method.pedido_pedidoId_combo_comboId_delete,
    aws_api_gateway_integration.pedido_pedidoId_combo_comboId_integration,

    # Métodos e integrações de preparação
    aws_api_gateway_method.preparacao_pedido_proximo_get,
    aws_api_gateway_integration.preparacao_pedido_proximo_integration,
    aws_api_gateway_method.preparacao_pedido_pedidoId_iniciar_preparacao_put,
    aws_api_gateway_integration.preparacao_pedido_pedidoId_iniciar_preparacao_integration,
    aws_api_gateway_method.preparacao_pedido_pedidoId_finalizar_preparacao_put,
    aws_api_gateway_integration.preparacao_pedido_pedidoId_finalizar_preparacao_integration,
    aws_api_gateway_method.preparacao_pedido_pedidoId_entregar_put,
    aws_api_gateway_integration.preparacao_pedido_pedidoId_entregar_integration,

    # Métodos e integrações de produtos
    aws_api_gateway_method.produto_listar_get,
    aws_api_gateway_integration.produto_listar_integration,
    aws_api_gateway_method.produto_buscar_id_get,
    aws_api_gateway_integration.produto_buscar_id_integration,
    aws_api_gateway_method.produto_listar_categoria_get,
    aws_api_gateway_integration.produto_listar_categoria_integration,
    aws_api_gateway_method.produto_remover_id_delete,
    aws_api_gateway_integration.produto_remover_id_integration,
    aws_api_gateway_method.produto_cadastrar_post,
    aws_api_gateway_integration.produto_cadastrar_integration,
    aws_api_gateway_method.produto_atualizar_put,
    aws_api_gateway_integration.produto_atualizar_integration
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "prod"
}

# Outputs API Gateway
output "rest_api_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
}

output "rest_api_url" {
  value = aws_api_gateway_stage.api_stage.invoke_url
}
