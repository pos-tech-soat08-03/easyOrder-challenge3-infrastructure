module "eks" {
  source = "terraform-aws-modules/eks/aws"
   version = "~> 20.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.31"
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    easyorder = {
      min_size     = 1
      max_size     = 10
      desired_size = 3
      vpc_security_group_ids = [aws_security_group.ssh_cluster.id]
      instance_types = ["t2.micro"]
    }
  }

# IAM Roles 
cluster_iam_role_name = "LabRole" 
# Additional IAM Roles 
map_roles = [ 
  { 
    rolearn = "arn:aws:iam::992382801838:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS" 
    username = "eks-service-role"
     groups = ["system:masters"] 
    }, { rolearn = "arn:aws:iam::992382801838:role/voclabs" 
    username = "voclabs-role" 
    groups = ["system:masters"]
     } 
    ]

  # access_entries = {
  #   # One access entry with a policy associated
  #   example = {
  #     principal_arn     = "arn:aws:iam::992382801838:role/LabRole"

  #     policy_associations = {
  #       example = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  # }
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.aws_eks.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.aws_eks.certificate_authority 
}