data "aws_availability_zones" "available" {}

data "aws_route53_zone" "main" {
  name         = var.zone_name
  private_zone = false
}

locals {
  project = "app"
  env     = terraform.workspace
  name    = "${local.project}-${local.env}"

  azs = data.aws_availability_zones.available.names

  public_subnets = [
    for index, az in local.azs : cidrsubnet(var.vpc_cidr, 8, index)
  ]

  backup_script = templatefile("${path.root}/assets/backup_mongo_to_s3.sh.tpl", {
    aws_region           = var.aws_region
    s3_bucket_name       = aws_s3_bucket.db_backups.bucket
    s3_backup_prefix     = var.backup_prefix
    mongo_container_name = var.mongo_container_name
    mongo_db_name        = var.mongo_db_name
  })

  user_data = templatefile("${path.root}/assets/userdata.tpl", {
    backup_script = local.backup_script
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.name
  cidr = var.vpc_cidr

  azs            = local.azs
  public_subnets = local.public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.tags
}

resource "aws_s3_bucket" "db_backups" {
  bucket = var.backup_bucket_name

  tags = merge(
    {
      Name = "${local.name}-db-backups"
    },
    var.tags,
  )
}

resource "aws_s3_bucket_public_access_block" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "db_backups" {
  bucket = aws_s3_bucket.db_backups.id

  rule {
    id     = "db-backup-retention"
    status = "Enabled"

    filter {
      prefix = "${var.backup_prefix}/"
    }

    transition {
      days          = var.backup_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.backup_expiration_days
    }
  }
}

module "app_ec2" {
  source = "./modules/ec2"

  name              = local.name
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_id         = module.vpc.public_subnets[0]
  vpc_id            = module.vpc.vpc_id
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  allocate_eip      = var.allocate_eip
  user_data         = local.user_data
  tags              = var.tags
}

resource "aws_iam_role_policy" "ec2_backup_to_s3" {
  name = "${local.name}-ec2-backup-to-s3"
  role = module.app_ec2.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BucketLocationAndList"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.db_backups.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.backup_prefix}/*"
            ]
          }
        }
      },
      {
        Sid    = "PutBackups"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.db_backups.arn}/${var.backup_prefix}/*"
      }
    ]
  })
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.fqdn
  type    = "A"
  ttl     = 300
  records = [module.app_ec2.public_ip]
}
