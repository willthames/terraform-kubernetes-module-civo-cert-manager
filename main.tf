data "kustomization_overlay" "resources" {
  resources = [
    "${path.module}/all"
  ]
  images {
    name     = "okteto/civo-webhook"
    new_name = "docker.io/willthames/cert-manager-webhook-civo"
    new_tag  = "0.2.0-4-g37125c6"
  }
  patches {
    target = {
      kind = "ClusterIssuer"
    }
    patch = <<-EOF
    - op: replace
      path: /spec/acme/email
      value: ${var.email_address}
    EOF
  }

  secret_generator {
    name = "civo-token"
    namespace = "cert-manager"
    literals = [
      "api-key=${var.civo_token}"
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.resources.ids_prio[0]
  manifest = data.kustomization_overlay.resources.manifests[each.value]
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
resource "kustomization_resource" "p1" {
  for_each   = data.kustomization_overlay.resources.ids_prio[1]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each   = data.kustomization_overlay.resources.ids_prio[2]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p1]
}
