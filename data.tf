data "aws_caller_identity" "current" {}

# TODO: data "terraform_remote_state" "lambda_arns" => get ARNs from lambdas-for-cognito

data "template_file" "products_api" {

  template = file("${path.module}/rest_api/products_api.yml")

  vars = {
    create_product_arn      = var.lambdas["create-product"]["arn"]
    aws_region              = var.aws_region
    lambda_identity_timeout = 5000 # var.lambda_identity_timeout

    get_product_arn         = var.lambdas["get-product"]["arn"]
    aws_region              = var.aws_region
    lambda_identity_timeout = 5000

    delete_product_arn      = var.lambdas["delete-product"]["arn"]
    aws_region              = var.aws_region
    lambda_identity_timeout = 5000
  }
}