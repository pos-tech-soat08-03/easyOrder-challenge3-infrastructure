resource "aws_security_group" "gruposeguranca" {
  name   = "gruposeguranca-${var.clusterName}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0    # ajustar para algo mais restritivo 
    to_port     = 0    # ajustar para algo mais restritivo 
    protocol    = "-1" # ajustar para algo mais restritivo 
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
