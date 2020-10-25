data cloudflare_zones homeassist {
  filter {
    name = var.dns_zone
  }
}
resource cloudflare_record domain {
  zone_id = lookup(data.cloudflare_zones.homeassist.zones[0], "id")
  name    = "*.ext"
  value   = var.external_ip
  type    = "A"
  ttl     = 3600
}