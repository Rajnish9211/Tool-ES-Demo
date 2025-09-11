terraform {
  backend "s3" {
    bucket         = "terraf-state-es"
    key            = "terraform/infra.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terra-statelocking-es"
    encrypt        = true
  }
}
