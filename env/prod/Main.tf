module "prod" {
  source = "../../infra"

  cluster_name     = "producao"
}


output "easyorder_cluster_endpoint" {
  value = module.prod.eks_cluster_endpoint
}

output "easyorder_cluster_certificate_authority" {
  value = module.prod.eks_cluster_certificate_authority
}
