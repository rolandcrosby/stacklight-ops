resource "aws_route53_record" "dev_stacklight_im" {
    zone_id = data.terraform_remote_state.common.outputs.stacklight_im_zone_id
    name = "dev.stacklight.im"
    type = "A"
    ttl = 60
    records = [aws_eip.swarm_public_ip.public_ip]
}