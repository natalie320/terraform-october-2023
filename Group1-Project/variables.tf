variable region {
  type        = string
  description = "This is aws region"
  default     = ""
  
}

variable stack {
  description = "this is name for tags"
  default     = "group1"
}

variable username {
  description = "DB username"
}

variable password {
  description = "DB password"
}

variable dbname {
  description = "db name"
}

variable ssh_key {
  default     = "~/.ssh/id_rsa.pub"
  description = "Default pub key"
}

variable ssh_priv_key {
  default     = "~/.ssh/id_rsa"
  description = "Default private key"
}

# variable ami {
#   type =string
#   default = ""
# }
variable vpc_cidr {
  type = string
  default = ""
}
variable public1_cidr {
  type = string
  default = ""
}
variable public2_cidr {
  type = string
  default = ""
}
variable private1_cidr {
  type = string
  default = ""
}