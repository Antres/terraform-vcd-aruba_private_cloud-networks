#variable "region" {}

variable "networks" {
  description               = "List of networks"
  
  type = list(object({
    name                    = string
    network                 = string # ex. 192.168.0.0/24
    routed                  = bool
    description             = string
  }))
  
  default                   = []
}
