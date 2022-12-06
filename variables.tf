variable "aws_region" {
  default = "us-west-2"
}

variable "app_prefix" {
  default = "lambdas-for-cognito"
}

variable "lambdas" {
  default = {
    "create-product" = {
      "arn"  = "arn:aws:lambda:us-west-2:919980474747:function:lambdas-for-cognito-dev-create-product"
      "name" = "lambdas-for-cognito-dev-create-product"
    }
    "delete-product" = {
      "arn"  = "arn:aws:lambda:us-west-2:919980474747:function:lambdas-for-cognito-dev-delete-product"
      "name" = "lambdas-for-cognito-dev-delete-product"
    }
    "get-product" = {
      "arn"  = "arn:aws:lambda:us-west-2:919980474747:function:lambdas-for-cognito-dev-get-product"
      "name" = "lambdas-for-cognito-dev-get-product"
    }
  }
}