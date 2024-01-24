resource "kubernetes_job" "create_db_user" {
  metadata {
    name      = "create-db-user"
    namespace = kubernetes_namespace.tf.id
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "create-db-user"
          image   = "postgres:alpine"
          command = ["psql"]
          args    = ["-Atx", "-d", "$(PGCONNSTRING)", "-f", "/data/create_app_user.sql"]
          volume_mount {
            mount_path = "/data"
            name       = "db-admin"
          }
          env {
            name = "PGCONNSTRING"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_admin.metadata.0.name
                key  = "postgres_dsn"
              }
            }
          }

        }
        volume {
          name = "db-admin"
          secret {
            secret_name = kubernetes_secret.db_admin.metadata.0.name
            items {
              key  = "create_app_user.sql"
              path = "create_app_user.sql"
            }
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 1
  }
  wait_for_completion = true
}
