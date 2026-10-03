variable "project_name" {
  description = "Repository name"
  type        = string
}

variable "project_description" {
  description = "Repository description"
  type        = string
  default     = null
}

variable "visibility" {
  description = "Repository visibility: public, private or internal"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be public, private or internal"
  }
}

variable "has_issues" {
  description = "Enable GitHub Issues on the repository"
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Archive the repository on destroy instead of deleting it"
  type        = bool
  default     = false
}

variable "vulnerability_alerts" {
  description = "Dependabot alerts for vulnerable dependencies; null leaves the repository's current setting alone"
  type        = bool
  default     = null
}

variable "dependabot_security_updates" {
  description = "Dependabot opens pull requests that fix vulnerable dependencies; needs vulnerability_alerts = true"
  type        = bool
  default     = false
}

variable "secret_scanning" {
  description = "Secret scanning plus push protection, which rejects a push that carries a secret; free on public repositories, a paid add-on on private ones"
  type        = bool
  default     = false
}

variable "template" {
  description = "Template repository to create from; null creates an empty repository"
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default = null
}

variable "default_branch" {
  description = "Default branch; an existing default branch of another name is renamed to it"
  type        = string
  default     = "master"
}

variable "branch" {
  description = "Extra branch cut from the default branch; null creates none"
  type        = string
  default     = null
}

variable "enable_branch_protection" {
  description = "Protect branches matching pattern; private repositories need a paid GitHub plan"
  type        = bool
  default     = true
}

variable "pattern" {
  description = "Branch protection pattern; null protects the default branch"
  type        = string
  default     = null
}

variable "enforce_admins" {
  description = "Enforce branch protection for repository administrators"
  type        = bool
  default     = null
}

variable "allows_deletions" {
  description = "Allow deletion of protected branches"
  type        = bool
  default     = null
}

variable "strict" {
  description = "Require branches to be up to date before merging"
  type        = bool
  default     = false
}

variable "enable_canonical_gitignore" {
  description = "Commit files/gitignore-canonical.txt as the repository .gitignore"
  type        = bool
  default     = true
}

variable "canonical_gitignore_branch" {
  description = "Branch the canonical .gitignore is committed to; null uses the default branch"
  type        = string
  default     = null
}

variable "overwrite_on_create" {
  description = "Overwrite an existing .gitignore when the file resource is created"
  type        = bool
  default     = false
}

variable "commit_author" {
  description = "Commit author name for the .gitignore commit; null uses the token's user. Set with commit_email"
  type        = string
  default     = null
}

variable "commit_email" {
  description = "Commit author email for the .gitignore commit; null uses the token's user. Set with commit_author"
  type        = string
  default     = null
}
