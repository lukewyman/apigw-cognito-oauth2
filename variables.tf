variable "aws_region" {
  default = "us-west-2"
}

variable "app_prefix" {
  default = "apigw-cognito-oauth2"
}

variable "the_lambdas" {
  type = list(string)
  default = [
    "create-product",
    "delete-product",
    "get-product"
  ]
}