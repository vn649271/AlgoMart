resource "google_cloud_run_service" "scribe" {
  name     = var.scribe_service_name
  location = var.region

  autogenerate_revision_name = false

  template {
    metadata {
      name = var.scribe_revision_name

      annotations = {
        "run.googleapis.com/vpc-access-connector" = var.vpc_access_connector_name
        # Temp setting for IAP to work.
        "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"

        "run.googleapis.com/cpu-throttling" = "false"

        # By default, Cloud Run will shut down containers after some amount of
        # time not receiving requests (maximum of 15 minutes). A new container
        # will immediately be started when a new request is received, but the
        # resulting cold start time can be unreasonable and lead to time outs,
        # primarily because of knex checking for migrations to run.
        #
        # Setting "minimum_instances" to 1 (or more) will force Cloud Run
        # to always keep that number of containers on-hand to avoid the
        # cold starts. Those containers will not receive CPU time when idle,
        # however; for that, see "always-on CPU allocation".
        "autoscaling.knative.dev/minScale" = 1

        # TODO
        #
        # maxScale is very conservative due to background tasks not needing
        # to scale up (and opening up unnecessary connection pools) and
        # fastify being highly capable of handling a decent amount of traffic.
        "autoscaling.knative.dev/maxScale" = 1
      }
    }

    spec {
      containers {
        image = var.scribe_image
    
        env {
          name  = "ALGOD_ENV"
          value = var.algod_env
        }

        env {
          name  = "ALGOD_SERVER"
          value = var.algod_host
        }

        env {
          name  = "ALGOD_PORT"
          value = var.algod_port
        }

        env {
          name  = "ALGOD_TOKEN"
          value = var.algod_key
        }

        env {
          name  = "API_KEY"
          value = var.api_key
        }

        env {
          name  = "CIRCLE_API_KEY"
          value = var.circle_key
        }

        env {
          name  = "CIRCLE_URL"
          value = var.circle_url
        }

        env {
          name  = "CMS_ACCESS_TOKEN"
          value = var.cms_key
        }

        env {
          name  = "CMS_URL"
          value = "https://${var.cms_domain_mapping}"
        }

        env {
          name  = "CREATOR_PASSPHRASE"
          value = var.api_creator_passphrase
        }

        env {
          name  = "DATABASE_URL"
          value = "postgresql://${google_sql_user.api_user.name}:${google_sql_user.api_user.password}@${google_sql_database_instance.database_server.private_ip_address}:5432/${google_sql_database.api_database.name}"
        }

        env {
          name  = "DATABASE_URL_READONLY"
          value = "postgresql://${google_sql_user.api_user.name}:${google_sql_user.api_user.password}@${google_sql_database_instance.database_server.private_ip_address}:5432/${google_sql_database.api_database.name}"
        }

        env {
          name  = "DATABASE_URL_WRITE"
          value = "postgresql://${google_sql_user.api_user.name}:${google_sql_user.api_user.password}@${google_sql_database_instance.database_server.private_ip_address}:5432/${google_sql_database.api_database.name}"
        }

        env {
          name  = "DATABASE_SCHEMA"
          value = var.api_database_schema
        }

        env {
          name  = "FUNDING_MNEMONIC"
          value = var.api_funding_mnemonic
        }

        env {
          name  = "HOST"
          value = "127.0.0.1"
        }
  
        env {
          name = "PORT"
          value = "8080"
        }

        env {
          name  = "NODE_ENV"
          value = var.api_node_env
        }

        env {
          name  = "SECRET"
          value = var.api_secret
        }

        env {
          name  = "PINATA_API_KEY"
          value = var.pinata_api_key
        }

        env {
          name  = "PINATA_API_SECRET"
          value = var.pinata_api_secret
        }

        env {
          name  = "SENDGRID_API_KEY"
          value = var.sendgrid_api_key
        }

        env {
          name  = "EMAIL_FROM"
          value = var.email_from
        }

        env {
          name  = "EMAIL_TRANSPORT"
          value = var.email_transport
        }

        env {
          name  = "EMAIL_NAME"
          value = var.email_name
        }

        env {
          name  = "SMTP_HOST"
          value = var.smtp_host
        }

        env {
          name  = "SMTP_PORT"
          value = var.smtp_port
        }

        env {
          name  = "SMTP_USER"
          value = var.smtp_user
        }

        env {
          name  = "SMTP_PASSWORD"
          value = var.smtp_password
        }

        env {
          name  = "WEB_URL"
          value = "https://${var.web_domain_mapping}"
        }

        env {
          name  = "LOG_LEVEL"
          value = "debug"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.run_api,
    google_project_service.vpcaccess_api,
    google_vpc_access_connector.connector,
  ]
}


resource "google_cloud_run_service_iam_member" "scribe_all_users" {
  service  = google_cloud_run_service.scribe.name
  location = google_cloud_run_service.scribe.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
