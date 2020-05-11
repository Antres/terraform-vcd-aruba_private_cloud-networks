terraform {
  required_version          = "> 0.12.0"
  experiments               = []
}

locals {
  #A named map of networks. local.network[<NETWORK_NAME>] => <NETWORK>
  networks                  = zipmap([for network in var.networks: network.name], var.networks)
  #A list of network names with attribute "routed" is setted to TRUE
  routed                    = compact([for network in var.networks: network.routed ? network.name : ""])
  #A list of network names with attribute "routed" is setted to FALSE
  isolated                  = compact([for network in var.networks: !network.routed ? network.name : ""])
}

resource "vcd_network_routed" "roueted" {
  for_each                  = local.routed
    
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    
    name                    = each.value
    description             = local.networks[each.value].description
      
    gateway                 = cidrhost(local.networks[each.value].network, 1)
    netmask                 = cidrnetmask(local.networks[each.value].network)
    edge_gateway            = var.region.edge.name
}
