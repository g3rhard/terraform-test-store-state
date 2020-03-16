provider "aws" {
  region                  = "us-east-2"
  profile                 = "terraform"
  shared_credentials_file = "~/.aws/terraform"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket                  = "terraform-up-and-running-state-g3-regain-backery-algorhytm"
    key                     = "global/s3/terraform.tfstate"
    region                  = "us-east-2"
    # Replace this with your DynamoDB table name!
    dynamodb_table          = "terraform-up-and-running-locks"
    encrypt                 = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-g3-regain-backery-algorhytm"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}

output "s3_bucket_arn" {
  # TODO: Fix value warning "Unknown token: 48:17 IDENT aws_s3_bucket.terraform_state.arn"
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}
output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}
