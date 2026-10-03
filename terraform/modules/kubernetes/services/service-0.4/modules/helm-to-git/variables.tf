variable "chart_dir" {
  type = string
}

variable "git_repository" {
  type = string
}

variable "git_branch" {
  type = string
}

variable "git_path" {
  type = string

  validation {
    condition     = can(regex("^[^/](.*[^/])?$", var.git_path))
    error_message = "The git_path value must be a non-empty repository path with no leading or trailing slash."
  }
}

variable "commit_author" {
  type    = string
  default = null
}

variable "commit_email" {
  type    = string
  default = null

  validation {
    condition     = (var.commit_author == null) == (var.commit_email == null)
    error_message = "Set commit_author and commit_email together, or leave both null."
  }
}

variable "exclude_patterns" {
  type    = list(string)
  default = ["^charts/.*\\.tgz$"]
}
