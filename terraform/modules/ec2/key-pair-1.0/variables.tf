variable "key_name" {
  description = "Key pair name, the same in every region"
  type        = string
}

variable "public_key" {
  description = "Public key as \"<type> <base64>\""
  type        = string
}

variable "regions" {
  description = "Regions the key is imported into"
  type        = list(string)
}
