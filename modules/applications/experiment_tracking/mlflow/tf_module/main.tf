# TODO: Replace with module from Anton Babenko
resource "aws_s3_bucket" "mlflow_artifacts_bucket" {
  count  = var.remote_tracking ? 1 : 0
  bucket = "ultimate-mlflow-artifacts-storage-bucket"
  tags   = var.tags
}

# create rds instance
module "mlflow_rds_backend" {
  source = "../../../../cloud/aws/rds"

  create_rds = var.remote_tracking

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block
  rds_instance_class   = var.rds_instance_class

  rds_identifier = "mlflow-backend"
  db_name        = "mlflowbackend"
  db_username    = "mlflow_backend_user"
  tags           = var.tags
}

module "mlflow" {
  source                  = "../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "mlflow-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  ec2_instance_type       = var.ec2_instance_type
  enable_rds_ingress_rule = var.remote_tracking

  ec2_user_data = var.remote_tracking ? templatefile("${path.module}/remote-cloud-init.tpl", {
    mlflow_version       = var.mlflow_version
    ec2_application_port = var.ec2_application_port
    db_instance_username = module.mlflow_rds_backend.db_instance_username
    db_instance_password = module.mlflow_rds_backend.db_instance_password
    db_instance_endpoint = module.mlflow_rds_backend.db_instance_endpoint
    db_instance_name     = module.mlflow_rds_backend.db_instance_name
    bucket_id            = aws_s3_bucket.mlflow_artifacts_bucket[0].id
    }) : templatefile("${path.module}/simple-cloud-init.tpl", {
    mlflow_version       = var.mlflow_version
    ec2_application_port = var.ec2_application_port
  })

  depends_on = [resource.aws_s3_bucket.mlflow_artifacts_bucket, module.mlflow_rds_backend]
}
