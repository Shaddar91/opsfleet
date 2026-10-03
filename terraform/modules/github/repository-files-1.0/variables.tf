variable "repository" {
  description = "Repository name, without the owner"
  type        = string
}

variable "branch" {
  description = "Branch the files are committed to"
  type        = string
}

variable "files" {
  description = "Repository path to file content; a path under .github/workflows needs a token with the workflow scope"
  type        = map(string)
}
