locals {
  security_policies = [
    {
      name        = "cloud-armor-backend-${terraform.workspace}"
      project     = local.project_id[terraform.workspace]
      description = "LBに適用するバックエンド セキュリティ ポリシー"
      rules = [
        {
          action      = "allow"
          description = "cloudace proxyを許可、shin.jeongho　IPを許可　	"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = [
                "35.194.105.118/32",
                "60.156.224.33/32",
                #uptime check ips
                "35.185.178.0/24",
                "35.186.144.0/23",
                "35.187.242.246/32",
                "35.198.192.0/18",
                "35.240.151.105/32"
              ]
            }
          }
          preview  = false
          priority = 1000
        },
        {
          action      = "deny(403)"
          description = "すべてのトラフィックを拒否"
          match = {
            versioned_expr = "SRC_IPS_V1"
            config = {
              src_ip_ranges = ["*"]
            }
          }
          preview  = false
          priority = 2147483647
        }
      ]
    }
  ]
}

resource "google_compute_security_policy" "default" {
  for_each = { for x in local.security_policies : x.name => x }

  project     = each.value.project
  name        = each.key
  description = each.value.description

  dynamic "rule" {
    for_each = [for r in each.value.rules : {
      action      = r.action
      description = r.description
      match       = r.match
      preview     = r.preview
      priority    = r.priority
    }]
    content {
      action      = rule.value.action
      description = rule.value.description
      preview     = rule.value.preview
      priority    = rule.value.priority

      match {
        versioned_expr = rule.value.match.versioned_expr
        config {
          src_ip_ranges = rule.value.match.config.src_ip_ranges
        }
      }
    }
  }
}
