
Repositório dedicado para Infraestrutura (Terraform)
- Inclui API GW, VPCs, Cognito, EKS etc

## Estrutura do Diretorio

docs                        - documentações e guias de implementação
src                         - diretório principal com arquivos .tf
|--terraform
    |--{tipo_de_recurso}

## Criação do Bucket de Backend

``` bash
aws s3api create-bucket \
    --bucket terraform-state-easyorder-$(uuidgen | tr -d - | tr '[:upper:]' '[:lower:]' ) \
    --region us-east-1
```