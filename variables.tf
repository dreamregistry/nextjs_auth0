variable "callbacks" {
  type    = list(string)
  default = ["http://localhost:3000/api/auth/callback"]
}

variable "allowed_logout_urls" {
  type    = list(string)
  default = ["http://localhost:3000", "http://localhost:3000/auth/logout"]
}


variable "app_base_url" {
  type    = string
  default = "http://localhost:3000"
}