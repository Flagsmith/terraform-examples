resource "kubernetes_secret" "db_admin" {
  metadata {
    name      = "db-admin"
    namespace = kubernetes_namespace.tf.id
  }

  data = {
    postgres_dsn          = var.db_admin_dsn
    "create_app_user.sql" = <<SQL
do
$$
begin
if not exists (SELECT * FROM pg_user WHERE usename = '${var.db_user_username}') then
    CREATE USER ${var.db_user_username} WITH PASSWORD '${var.db_user_password}';
    GRANT ALL PRIVILEGES ON DATABASE flagsmith TO ${var.db_user_username};
end if;
if not exists (SELECT * FROM pg_user WHERE usename = '${var.db_analytics_user_username}') then
    CREATE USER ${var.db_analytics_user_username} WITH PASSWORD '${var.db_analytics_user_password}';
    GRANT ALL PRIVILEGES ON DATABASE flagsmith_analytics TO ${var.db_analytics_user_username};
end if;
end
$$
;
SQL
  }
}

resource "kubernetes_secret" "db_app" {
  metadata {
    name      = "db-flagsmith"
    namespace = kubernetes_namespace.flagsmith.id
  }

  data = {
    app_database_dsn       = "postgresql://${var.db_user_username}:${var.db_user_password}@${var.db_host}:5432/flagsmith"
    analytics_database_dsn = "postgresql://${var.db_analytics_user_username}:${var.db_analytics_user_password}@${var.db_host}:5432/flagsmith_analytics"
  }
}

resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-flagsmith"
    namespace = kubernetes_namespace.flagsmith.id
  }

  data = {
    flagsmith_django_secret_key    = var.flagsmith_django_secret_key
    sendgrid_api_key               = var.sendgrid_api_key
    flagsmith_on_flagsmith_api_key = var.flagsmith_on_flagsmith_api_key
  }
}
