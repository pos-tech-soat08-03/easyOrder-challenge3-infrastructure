
output "easyorder_cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "easyorder_cluster_certificate_authority" {
  value = aws_eks_cluster.eks-cluster.certificate_authority
}

output "easyorder_cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}

output "vpc_id" {
  value = aws_eks_cluster.eks-cluster.vpc_config[*].vpc_id
}

output "subnet_ids" {
  value = aws_eks_cluster.eks-cluster.vpc_config[*].subnet_ids[*]
}

output "security_group_id" {
  value = aws_eks_cluster.eks-cluster.vpc_config[*].security_group_ids[*]
}
