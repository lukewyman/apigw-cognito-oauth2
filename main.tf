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

resource "aws_api_gateway_stage" "products_api_dev" {
  deployment_id = aws_api_gateway_deployment.products_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.products_api.id
  stage_name    = "products-api-dev"
}

resource "aws_lambda_permission" "api_gateway_invoke_create_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambdas["create-product"]["name"]
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.products_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_get_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambdas["get-product"]["name"]
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.products_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_invoke_delete_product" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambdas["delete-product"]["name"]
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.products_api.execution_arn}/*/*"
}