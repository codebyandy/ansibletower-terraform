
variable "tag_name" {
  type = string
}
variable "tag_ttl" {
  type = string
}
variable "tag_owner" {
  type = string
}
variable "size" {
  type = string
  default = "t2.large"
}
variable "tower_version" {
  type = string
  default = "3.7.4-1"
}
variable "ssh_key" {
  type = string
}
