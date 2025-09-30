resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "dev"
  auto_deploy = true
}
