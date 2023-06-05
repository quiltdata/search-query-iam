provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account]
}

resource "aws_iam_role" "role" {
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "policy" {
  name        = "athena_es_policy"
  description = "Read Athena, OpenSearch, Glue"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition"
        ],
        Resource = [
          "*"
        ]
      },
      {
        "Sid" : "S3ReadOnly",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      {
        "Sid" : "S3WriteResults",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.results_bucket}",
          "arn:aws:s3:::${var.results_bucket}/*"
        ]
      },
      {
        "Sid" : "ESGet",
        Effect = "Allow",
        Action = [
          "es:ESHttpGet"
        ],
        Resource = "${var.opensearch_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_instance_profile" "profile" {
  name = "ec2_profile"
  role = aws_iam_role.role.name
  tags = var.tags
}

resource "aws_key_pair" "auth" {
  key_name   = "ec2_ssh_key"
  public_key = file("${var.public_key_path}/id_rsa.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [
    var.security_group_id,
    aws_security_group.allow_ssh.id
  ]

  key_name             = aws_key_pair.auth.key_name
  iam_instance_profile = aws_iam_instance_profile.profile.name

  tags = merge(
    var.tags,
    {
      Name = "quilt-search-query"
    }
  )
}

output "ssh_login" {
  description = "SSH login string"
  value       = "ssh -i id_rsa ec2-user@${aws_instance.ec2.public_ip}"
}
