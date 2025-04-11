/*GitHub Appとのsecret*/
data "google_secret_manager_secret" "github-token-secret" {
  secret_id = "github-token-secret"
  project   = local.project_id
}

data "google_secret_manager_secret_version" "github-token-secret-version" {
  secret  = data.google_secret_manager_secret.github-token-secret.id
  version = "latest"
  project = local.project_id
}

/* リポジトリ接続 */
resource "google_cloudbuildv2_connection" "github-connection" {
  location = "asia-northeast1"
  name     = "github-connection"

  github_config {
    app_installation_id = var.installation_id
    authorizer_credential {
      oauth_token_secret_version = "projects/832325408614/secrets/github-connection-github-oauthtoken-c51ea2/versions/latest"
    }
  }
}

/*GitHubリポジトリとの接続*/
resource "google_cloudbuildv2_repository" "github-repository" {
  location          = local.region
  name              = "repository"
  parent_connection = google_cloudbuildv2_connection.github-connection.name
  remote_uri        = "https://github.com/saikasyndrome/terraform-gcp-cicd-pipeline.git"
}

/*Cloud Build plan トリガーの作成: PRされた際のトリガー */

resource "google_cloudbuild_trigger" "pr_trigger" {
  name = "pr-trigger"
  location = local.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.github-repository.id
    pull_request {
      branch = "^main$"
    }
  }

  service_account = google_service_account.cloudbuild_service_account["cloud-build"].id
  filename        = "cloudbuild/pr-plan.yaml"
  depends_on = [
    google_project_iam_member.role
  ]
}


/*Cloud Buildトリガーの作成: dev applyをした際のトリガー */
resource "google_cloudbuild_trigger" "dev-tag-push-trigger" {
  name = "dev-tag-push-trigger"

  location = local.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.github-repository.id
    push {
      tag = "dev_*"
    }
  }

  substitutions = {
    _ENV = "dev"
  }

  service_account = google_service_account.cloudbuild_service_account["cloud-build"].id
  filename        = "cloudbuild/apply.yaml"
  depends_on = [
    google_service_account.cloudbuild_service_account
  ]
}

/*Cloud Buildトリガーの作成: prd applyをした際のトリガー */
resource "google_cloudbuild_trigger" "prd-tag-push-trigger" {
  name = "prd-tag-push-trigger"

  location = local.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.github-repository.id
    push {
      tag = "prd_*"
    }
  }

  substitutions = {
    _ENV = "prd"
  }

  service_account = google_service_account.cloudbuild_service_account["cloud-build"].id
  filename        = "cloudbuild/apply.yaml"
  depends_on = [
    google_service_account.cloudbuild_service_account
  ]
}
