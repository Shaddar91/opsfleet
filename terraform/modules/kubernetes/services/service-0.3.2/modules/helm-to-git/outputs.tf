output "files" {
  value = { for k, f in github_repository_file.chart : k => f.commit_sha }
}

output "repo_url" {
  value = data.github_repository.this.ssh_clone_url
}
