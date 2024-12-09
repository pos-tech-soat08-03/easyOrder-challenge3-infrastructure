variable "regionDefault" {
  default = "us-east-1"
}

variable "clusterName" {
  description = "Nome do cluster"
}

variable "bucket" {
  description = "Nome do bucket S3 para armazenar o estado do Terraform"
  
}

variable "instanceType" {
  default = "t2.micro"
}

variable "accountIdVoclabs" {
  description = "ID da conta AWS"
}


variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}
