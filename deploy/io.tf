variable external_ip {
    description = "external ip"
    default = "69.129.196.87"
}

variable dns_zone {
    description = "Cloudflare zone (already exists)"
    default = "loeber.live"
}

variable cloudflare_email {
    type = string
    description = "cloudflare email address"
    default = "zloeber@gmail.com"
}

variable cloudflare_api_key {
    type = string
    description = "cloudflare api key"
}
