locals {

  tags = {
    created_by = "terraform"
  }

  app_prefix = "${var.app_prefix}-${terraform.workspace}"
}