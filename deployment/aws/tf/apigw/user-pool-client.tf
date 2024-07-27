data "aws_cognito_user_pools" "pool" {
	name = "nodejs-oidc-boilerplate"
}

resource "aws_cognito_user_pool_client" "client" {
  name                = "nodejs-oidc-boilerplate-client"
  user_pool_id        = data.aws_cognito_user_pools.pool.ids[0]
	callback_urls       = [length(var.app_domain_name) > 0 ? "https://${var.app_domain_name}/oidc-callback" : "${aws_apigatewayv2_api.nodjs_boilerplate.api_endpoint}/oidc-callback"]
	generate_secret     = true
	allowed_oauth_flows = ["code"]
}

resource "aws_ssm_parameter" "client_secret" {
  name        = "/config/${var.app_name}/client-secret"
  type        = "SecureString"
	value       = aws_cognito_user_pool_client.client.client_secret
}
