terraform {
  required_version          = "> 0.12.0"
  experiments               = []
}

locals {
  defaults_dns               = tolist(["8.8.8.8", "1.1.1.1"])
  defaults_lease_time        = 3600
  
  #A named map of networks. local.network[<NETWORK_NAME>] => <NETWORK>
  networks                  = zipmap(var.networks[*].name, var.networks)
    
  # A list of network names with attribute "routed" is setted to TRUE
  routed                    = compact([for network in var.networks: network.routed ? network.name : ""])
    
  # A list of network names with attribute "routed" is setted to FALSE
  isolated                  = compact([for network in var.networks: !network.routed ? network.name : ""])
  
  # A list of network names where DHCP feature is required
  dhcp                      = compact([for network in var.networks: network.dhcp.enable ? network.name : ""])
  
  egress                    = { for item in flatten([ for network in var.networks: 
                                              [ for network_egress in network.egress: 
                                                { name = network.name, egress = network_egress}]]):
                                  uuidv5("x500", format("CN=%s,OU=%,DC=%s,DC=%s,DC=%s", item.with_address, item.name, "networks", "aruba_private_cloud", "terraform")) => item }
}
    
