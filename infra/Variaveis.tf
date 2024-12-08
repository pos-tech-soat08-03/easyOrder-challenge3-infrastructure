variable "regionDefault" {
  default = "us-east-1"
}

variable "projectName" {
  default = "nginx"
}

variable "vpcCidr" {
  default = "10.0.0.0/16"
}

variable "instanceType" {
  default = "t2.micro"
}

variable "accountIdVoclabs" {}


variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}
