resource "aws_eks_cluster" "eks-cluster" {
  name     = var.clusterName
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    security_group_ids = [aws_security_group.gruposeguranca.id]
    subnet_ids         = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  }

  access_config {
    authentication_mode = var.accessConfig
  }
}
