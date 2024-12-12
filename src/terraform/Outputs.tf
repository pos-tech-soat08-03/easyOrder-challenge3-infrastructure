
output "easyorder_cluster_endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "easyorder_cluster_certificate_authority" {
  value = aws_eks_cluster.eks-cluster.certificate_authority
}

output "easyorder_cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}
