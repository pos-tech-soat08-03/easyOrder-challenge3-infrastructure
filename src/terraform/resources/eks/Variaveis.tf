variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}
variable "accountIdVoclabs" {
  description = "ID da conta AWS"
}
variable "bucket" {
  default = "terraform-state-easyorder"
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