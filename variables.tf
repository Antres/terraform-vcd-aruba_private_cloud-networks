variable "region" {}

variable "networks" {
  description               = "List of networks"
  
  type = list(object({
    name                    = string                                    # MUST BE unique
    
    network                 = string                                    # ex. 192.168.0.0/24
    routed                  = bool                                      # If TRUE a resource vcd_network_routed will be used, otherwise vcd_network_isolated
    
    description             = string                                    # Free text decription
    
    dhcp                    = object({                                  # If end_range is empty, dhcp will be ignored
                                start_range       = string              # First address to assign. If empty second ip in network will be used
                                end_range         = string              # Last address to assign
                                dns               = set(string)         # A list of DNS address to assign (only 2 will be used)
                              })
  }))
  
  default                   = []
}
