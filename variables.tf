variable "remote_user" {
    type = string
    default = "vpnuser"
  
}

variable "remote_uid" {
    type = string
    default = "28679"
  
}
variable "remote_group" {
    type = string
    default = "users"
  
}
variable "remote_password" {
    type = string
    default = "'CHANGEME4321'"
  
}

variable "remote_ssh_key" {
    type = string
    default = "vpnuserssh2.pub"
}
