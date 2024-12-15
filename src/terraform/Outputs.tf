
output "easyorder_cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "easyorder_cluster_certificate_authority" {
  value = aws_eks_cluster.eks-cluster.certificate_authority
}

output "easyorder_cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "security_group_id" {
  value = aws_security_group.gruposeguranca.id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
