variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

# Função Lambda
resource "aws_lambda_function" "cpf_validation" { # Recurso da função Lambda + nome lógico do recurso DENTRO DO TERRAFORM
  function_name = "EasyOrder-Lambda-CPFValidation"
  /*
    AMBIENTE DE EXECUÇÃO PARA A FUNÇÃO LAMBDA
    Isso indica que a função Lambda será executada usando o runtime Python 3.13.
    Precisamos nos certificar que a versão especificada seja suportada pela AWS Lambda.
  */
  runtime       = "python3.13"
  /*
    O parâmetro role especifica o ARN (Amazon Resource Name) da função IAM (Identity and Access Management) que a função Lambda assumirá ao ser executada.
    Esta função IAM define as permissões que a função Lambda terá.

    aws_iam_role.lambda_exec.arn refere-se ao ARN de uma função IAM chamada lambda_exec que foi definida em outro lugar no código Terraform.
    Esta função IAM deve ter permissões necessárias para que a função Lambda possa executar suas tarefas, como acessar outros serviços AWS.
    A nomenclatura lambda_exec não é padrão, é apenas um nome lógico escolhido por nós. 
    Podemos nomear a função IAM como preferir, desde que seja consistente e descritivo.
  */
  role          = aws_iam_role.lambda_exec.arn # ARN da IAM que a função Lambda utilizará
  /*
    O parâmetro handler especifica o nome da função que a AWS Lambda invocará quando a função Lambda for executada.
    O nome da função é composto por dois elementos separados por um ponto: o nome do arquivo e o nome da função.
    Neste caso, o nome do arquivo é lambda_function e o nome da função é lambda_handler.
  */
  handler       = "lambda_function.lambda_handler"

  /*
    O parâmetro filename especifica o caminho para o arquivo que contém o código da função Lambda.
    Este arquivo deve ser um arquivo zip que inclui todo o código e dependências necessárias para a execução da função.
    Isso indica que o código da função Lambda está contido no arquivo lambda_function.zip.
    Este arquivo deve estar presente no diretório onde o Terraform está sendo executado ou em um caminho acessível.
  */
  # filename      = "lambda_function.zip"
  filename      = data.archive_file.lambda_zip.output_path

  /*
    O parâmetro source_code_hash especifica o hash SHA256 do arquivo de código da função Lambda.
    Isso é usado pelo Terraform para determinar se o código da função Lambda foi alterado desde a última execução.
    Se o código foi alterado, o Terraform atualizará a função Lambda com o novo código.
    Se o código não foi alterado, o Terraform não fará alterações na função Lambda.
    Isso ajuda a garantir que a função Lambda seja atualizada apenas quando necessário.
  */
  # source_code_hash = filebase64sha256("lambda_function.zip")
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      # Variáveis de ambiente, se necessário
    }
  }
}

/*
  O recurso archive_file é usado para criar um arquivo zip contendo o código da função Lambda.
  Ele toma um diretório de origem e cria um arquivo zip de saída contendo o conteúdo desse diretório.
  Neste caso, o diretório de origem é lambda_code e o arquivo de saída é lambda_function.zip.
  O arquivo zip gerado é usado como o código da função Lambda.
*/
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "lambda_code"
  output_path = "lambda_function.zip"
}

/*
  O recurso aws_iam_role é usado para criar uma função IAM que a função Lambda usará para executar.
  A função IAM define as permissões que a função Lambda terá ao ser executada.
  Neste caso, a função IAM é chamada lambda_exec e tem uma política que permite que a função Lambda acesse os logs do CloudWatch.
*/
resource "aws_iam_role" "lambda_exec" {
  /*
    !!!!!!! ATENÇÃO !!!!!!!
    Em Terraform, o nome dado após o tipo de recurso é um identificador lógico usado dentro das configurações do Terraform,
    enquanto o atributo name dentro do bloco do recurso especifica o nome real do recurso na AWS.
  */

  /*
    O parâmetro name especifica o nome da função IAM.
    Neste caso, o nome da função IAM é lambda_exec.
    Este nome é usado para identificar a função IAM no código Terraform e em outros lugares onde a função IAM é referenciada.
  */
  name = "lambda_exec_role"

  /*
    Esse trecho de código em Terraform define uma política de confiança ("assume role policy") para um papel (role) no AWS Identity and Access Management (IAM).

    Em termos simples, ele está permitindo que o serviço AWS Lambda assuma esse papel, ou seja,
    está concedendo à AWS Lambda as permissões associadas a esse papel IAM.

    Vamos detalhar cada parte:
        jsonencode({ ... }): Converte o bloco de código em formato JSON, que é o formato esperado pela AWS para políticas IAM. (ESPECIFICAMENTE AWS)
        Version = "2012-10-17": Especifica a versão do documento de política. Essa é a data padrão utilizada pela AWS.
        Statement: É uma lista de declarações que definem quem pode assumir o papel e sob quais condições.
            Effect = "Allow": Indica que a ação é permitida.
            Action = "sts:AssumeRole": Especifica que a ação permitida é assumir o papel.
            Principal = { Service = "lambda.amazonaws.com" }: Define que o principal (quem está recebendo a permissão) é o serviço AWS Lambda.
            
    Em resumo, este código permite que funções Lambda utilizem este papel IAM, o que é necessário para que elas possam executar com as permissões definidas.
  */
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

/*
  O recurso aws_iam_role_policy é usado para anexar uma política a uma função IAM.
  A política define as permissões que a função IAM terá ao ser executada.
  Neste caso, a política permite que a função IAM acesse os logs do CloudWatch.
*/
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

/*
  Isso cria uma API REST usando o serviço API Gateway da AWS.

  - resource "aws_api_gateway_rest_api" "cpf_api": Declara a criação de um novo recurso do API Gateway REST API e o 
    identifica internamente como "cpf_api" no Terraform.
  - name = "EasyOrder-ApiGateway-CPFValidation": Define o nome da API que aparecerá no console da AWS. Neste caso, será "EasyOrder-ApiGateway-CPFValidation".
  - description = "API Gateway para validar CPF": Fornece uma descrição para a API, ajudando a identificar seu propósito dentro do console da AWS.
*/
resource "aws_api_gateway_rest_api" "cpf_api" {
  name        = "EasyOrder-ApiGateway-CPFValidation"
  description = "API Gateway para validar CPF"
}

/*
  Isso cria um recurso de API Gateway REST API.

  - resource "aws_api_gateway_resource" "cpf_resource": Declara a criação de um novo recurso de API Gateway REST API e o 
    identifica internamente como "cpf_resource" no Terraform.
  - rest_api_id = aws_api_gateway_rest_api.cpf_api.id: Especifica o ID da API REST à qual o recurso pertencerá.
  - parent_id = aws_api_gateway_rest_api.cpf_api.root_resource_id: Especifica o ID do recurso pai. Neste caso, o recurso pai é o recurso raiz da API.
  - path_part = "validate": Especifica o caminho do recurso. Neste caso, o caminho do recurso é "validate".
*/
resource "aws_api_gateway_resource" "cpf_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.cpf_api.id
  parent_id   = aws_api_gateway_rest_api.cpf_api.root_resource_id
  path_part   = "{proxy+}"
}

/*
  Isso cria um método de API Gateway.

  - resource "aws_api_gateway_method" "cpf_proxy_method": Declara a criação de um novo método de API Gateway e o 
    identifica internamente como "cpf_proxy_method" no Terraform.
  - rest_api_id = aws_api_gateway_rest_api.cpf_api.id: Especifica o ID da API REST à qual o método pertencerá.
  - resource_id = aws_api_gateway_resource.cpf_proxy_resource.id: Especifica o ID do recurso ao qual o método será associado.
  - http_method = "GET": Especifica o método HTTP que o método de API Gateway aceitará. Neste caso, é "GET".
  - authorization = "NONE": Especifica o tipo de autorização necessária para acessar o método. Neste caso, é "NONE" (nenhuma autorização necessária).
*/
resource "aws_api_gateway_method" "cpf_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.cpf_api.id
  resource_id   = aws_api_gateway_resource.cpf_proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_stage" "prod_stage" {
  deployment_id = aws_api_gateway_deployment.cpf_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.cpf_api.id
  stage_name    = "PRODUCTION"
}

/*
  Isso cria uma integração de API Gateway.

  - resource "aws_api_gateway_integration" "cpf_proxy_integration": Declara a criação de uma nova integração de API Gateway e o 
    identifica internamente como "cpf_proxy_integration" no Terraform.
  - rest_api_id = aws_api_gateway_rest_api.cpf_api.id: Especifica o ID da API REST à qual a integração pertencerá.
  - resource_id = aws_api_gateway_resource.cpf_proxy_resource.id: Especifica o ID do recurso ao qual a integração será associada.
  - http_method = aws_api_gateway_method.cpf_proxy_method.http_method: Especifica o método HTTP que a integração aceitará. Neste caso, é o método HTTP do método de API Gateway.
  - integration_http_method = "POST": Especifica o método HTTP que a integração usará para chamar o backend. Neste caso, é "POST".
  - type = "AWS_PROXY": Especifica o tipo de integração. Neste caso, é uma integração de proxy AWS.
  - uri = aws_lambda_function.cpf_validation.invoke_arn: Especifica o ARN da função Lambda que a integração chamará.
*/
resource "aws_api_gateway_integration" "cpf_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cpf_api.id
  resource_id             = aws_api_gateway_resource.cpf_proxy_resource.id
  http_method             = aws_api_gateway_method.cpf_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" // Integração de proxy AWS
  uri                     = aws_lambda_function.cpf_validation.invoke_arn
  depends_on              = [
    aws_api_gateway_method.cpf_proxy_method,
  ]
}

/*
  Isso cria uma permissão de função Lambda.

  - resource "aws_lambda_permission" "allow_api_gateway": Declara a criação de uma nova permissão de função Lambda e o 
    identifica internamente como "allow_api_gateway" no Terraform.
  - statement_id = "AllowExecutionFromAPIGateway": Especifica o ID da declaração de permissão. Neste caso, é "AllowExecutionFromAPIGateway".
  - action = "lambda:InvokeFunction": Especifica a ação que a permissão permitirá. Neste caso, é "lambda:InvokeFunction".
  - function_name = aws_lambda_function.cpf_validation.arn: Especifica o ARN da função Lambda que a permissão permitirá chamar.
  - principal = "apigateway.amazonaws.com": Especifica o principal que a permissão permitirá chamar a função Lambda. Neste caso, é o serviço API Gateway.
  - source_arn = "${aws_api_gateway_rest_api.cpf_api.execution_arn}-*-*": Especifica o ARN da origem da chamada. Neste caso, é o ARN da API Gateway.
*/
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpf_validation.arn
  principal     = "apigateway.amazonaws.com"

  # Permitir que o API Gateway específico invoque a função Lambda
  source_arn = "${aws_api_gateway_rest_api.cpf_api.execution_arn}/*/*"
}


/*
  O trecho abaixo define um recurso do Terraform para criar uma implantação da API Gateway na AWS.

  - resource "aws_api_gateway_deployment" "cpf_deployment": Declara um novo recurso de deployment chamado cpf_deployment para a API Gateway.
  - depends_on = [aws_api_gateway_integration.lambda_integration]: Especifica que este deployment depende da integração Lambda definida em 
    aws_api_gateway_integration.lambda_integration.
    Isso garante que a integração esteja configurada antes da implantação.
  - rest_api_id = aws_api_gateway_rest_api.cpf_api.id: Vincula o deployment à API REST identificada por aws_api_gateway_rest_api.cpf_api.id.
  - stage_name = "PRODUCTION": Define o nome do estágio como "PRODUCTION". A API será implantada no estágio de produção chamado PRODUCTION.
*/
resource "aws_api_gateway_deployment" "cpf_deployment" {
  depends_on = [aws_api_gateway_integration.cpf_proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.cpf_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.cpf_proxy_integration))
  }
}

output "api_gateway_url" {
  # value = "${aws_api_gateway_rest_api.cpf_api.name}/${aws_api_gateway_stage.prod_stage.stage_name}/${aws_lambda_function.cpf_validation.function_name}"
  value = "https://${aws_api_gateway_rest_api.cpf_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.prod_stage.stage_name}/${aws_lambda_function.cpf_validation.function_name}"
}