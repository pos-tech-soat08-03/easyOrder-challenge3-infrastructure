resource "kubernetes_deployment" "easy-order-API" {
  metadata {
    name = "easy-order-api"
    labels = {
      nome = "easy-order"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        nome = "easy-order"
      }
    }

    template {
      metadata {
        labels = {
          nome = "easy-order"
        }
      }

      spec {
        container {
          image = #colocar imagem
          name  = "easy-order"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/clientes/"
              port = 8000
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "LoadBalancer" {
  metadata {
    name = "load-balancer-easy-order-api"
  }
  spec {
    selector = {
      nome = "easy-order"
    }
    port {
      port = 8000
      target_port = 8000
    }
    type = "LoadBalancer"
  }
}

data "kubernetes_service" "nomeDNS" {
    metadata {
      name = "load-balancer-easy-order-api"
    }
}

output "URL" {
  value = data.kubernetes_service.nomeDNS.status
}