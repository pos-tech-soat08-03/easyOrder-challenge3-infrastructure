data "aws_iam_role" "labrole" {
  name = "LabRole"
}

variable "accountIdVoclabs" {
  description = "ID da conta AWS"
  default = "442742266432"
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
variable "bucketStates" {
  description = "The S3 bucket to store the Terraform state file"
  default = "terraform-state-easyorder"
}
variable "keyStates" {
  description = "The S3 key to store the Terraform state file"
  default = "easyorder-infra/terraform.tfstate"
}
