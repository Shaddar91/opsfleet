locals {
  helm_repo_url     = "https://github.com/${local.helm_repo_full_name}.git"
  helm_repo_ssh_url = "git@github.com:${local.helm_repo_full_name}.git"

  applications = {
    for name, app in var.applications : name => merge(app, {
      source = merge({ repoURL = local.helm_repo_url }, app.source)
    })
  }

  projects = {
    for name, project in var.projects : name => merge(project, {
      sourceRepos = distinct(concat([local.helm_repo_url, local.helm_repo_ssh_url], try(project.sourceRepos, [])))
    })
  }
}
