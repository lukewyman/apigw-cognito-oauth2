resource "aws_api_gateway_rest_api" "products_api" {
  name           = "${local.app_prefix}-products-api"
  description    = "Products API"
  api_key_source = "HEADER"
  body           = data.template_file.products_api.rendered

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "products_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.products_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.products_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.products_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.products_api.id
  stage_name    = "${terraform.workspace}"
}

resource "aws_lambda_permission" "api_gateway_invoke_create_product" {
  for_each = toset(var.the_lambdas)

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambdas_for_cognito.outputs.lambdas[each.key]["name"]
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.products_api.execution_arn}/*/*"
}

resource "aws_cognito_user_pool" "product_user_pool" {
  name = "${local.app_prefix}-products-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]
  password_policy {
    minimum_length = 6
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Account Confirmation"
    email_message        = "Your confirmation code is {####}"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain = "productapipool"

  user_pool_id = aws_cognito_user_pool.product_user_pool.id
}

resource "aws_cognito_user_pool_client" "product_user_pool_client" {
  name = "${local.app_prefix}-products-client"

  user_pool_id = aws_cognito_user_pool.product_user_pool.id

  allowed_oauth_flows = ["client_credentials"]

  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_scopes = [
    "products/read_product",
    "products/create_product",
    "products/delete_product"
  ]

  generate_secret = true

  supported_identity_providers = ["COGNITO"]

  depends_on = [aws_cognito_resource_server.product_server]
}

resource "aws_cognito_resource_server" "product_server" {
  name         = "${local.app_prefix}-products-client-server"
  identifier   = "products"
  user_pool_id = aws_cognito_user_pool.product_user_pool.id

  scope {
    scope_name        = "read_product"
    scope_description = "Read product details"
  }

  scope {
    scope_name        = "create_product"
    scope_description = "Create a new product"
  }

  scope {
    scope_name        = "delete_product"
    scope_description = "Delete a product"
  }
}