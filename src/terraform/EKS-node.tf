resource "aws_eks_node_group" "node-group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "node-group-${var.clusterName}"

  node_role_arn = data.aws_iam_role.labrole.arn
  subnet_ids    = module.vpc.private_subnets

  #disk_size       = 50
  instance_types = [var.instanceType]

  scaling_config {
    desired_size = 2
    max_size     = 4 #era 6
    min_size     = 1 #era 2
  }
  # update_config {
  #   max_unavailable = 1
  # }
}
