terraform {
  backend "s3" {
    bucket         = "terraform-tool-es"
    key            = "terraform/infra.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "state-tool-elasticsearch"
    encrypt        = true
  }
}
