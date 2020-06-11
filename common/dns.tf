resource "aws_route53_delegation_set" "default" {
  reference_name = "default"
}

resource "aws_route53_zone" "stacklight_app" {
    name = "stacklight.app."
    delegation_set_id = aws_route53_delegation_set.default.id
}

resource "aws_route53_zone" "stacklight_im" {
    name = "stacklight.im."
    delegation_set_id = aws_route53_delegation_set.default.id
}

output "stacklight_app_zone_id" {
  value = aws_route53_zone.stacklight_app.id
}

output "stacklight_im_zone_id" {
  value = aws_route53_zone.stacklight_im.id
}

output "name_servers" {
  value = aws_route53_delegation_set.default.name_servers
}