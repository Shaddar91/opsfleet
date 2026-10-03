locals {
  #GitHub issues immutable subjects for this repo: owner and repository each carry their numeric id, read from the API
  subject_prefix = "repo:${data.github_user.owner.login}@${data.github_user.owner.id}/${data.github_repository.repo.name}@${data.github_repository.repo.repo_id}"
}
