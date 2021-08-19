provider "aws" {
  region  = var.region
  profile = lookup(var.default_tags, "Environment", "Provide Proper Key")
}