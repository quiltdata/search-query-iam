variable "account" {
  type        = string
  description = "Host account"
  default     = "YOUR_VALUE"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "YOUR_VALUE"
}

variable "tags" {
  type        = map(string)
  description = "Common tags to be attached to all resources"
  default = {
    Environment = "dev"
    Owner       = "person"
    Purpose     = "teleology"
  }
}


variable "results_bucket" {
  type        = string
  description = "Athena query results bucket"
  default     = "YOUR_VALUE"
}

variable "opensearch_arn" {
  type        = string
  description = "The ARN of the OpenSearch domain"
  default     = "YOUR_VALUE"
}

variable "ami_id" {
  type        = string
  description = "The ID of the AMI to use"
  default     = "YOUR_VALUE"
}

variable "instance_type" {
  type        = string
  description = "The type of the EC2 instance"
  default     = "YOUR_VALUE"
}

variable "security_group_id" {
  type        = string
  description = "Id of the SearchClusterAccessorSecurityGroup"
  default     = "YOUR_VALUE"
}

variable "subnet_id" {
  type        = string
  description = "Id of (public) subnet for EC2 instance; must match Quilt VPC if private cluster"
  default     = "YOUR_VALUE"
}

variable "vpc_id" {
  type        = string
  description = "VPC id for subnet (and OpenSearch for private clusters)"
  default     = "YOUR_VALUE"
}

variable "public_key_path" {
  type        = string
  description = "Local path to public key for EC2 instance"
  default     = "YOUR_VALUE"
}

