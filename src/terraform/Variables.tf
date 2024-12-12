data "aws_iam_role" "labrole" {
  name = "LabRole"
}

variable "backendBucketVoclabs" {
  description = "Bucket para armazenamento de arquivos de backend"
}
variable "accountIdVoclabs" {
  description = "ID da conta AWS"
}
variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}
variable "clusterName" {
  default = "easyorder"
}
variable "instanceType" {
  default = "t2.micro"
}
variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}
variable "regionDefault" {
  default = "us-east-1"
}