terraform {
  required_version          = "> 0.12.0"
  experiments               = []
}

locals {
  #A named map of networks. local.network[<NETWORK_NAME>] => <NETWORK>
  networks                  = zipmap([for network in var.networks: network.name], var.networks)
    
  # A list of network names with attribute "routed" is setted to TRUE
  routed                    = toset(compact([for network in var.networks: network.routed ? network.name : ""]))
    
  # A list of network names with attribute "routed" is setted to FALSE
  isolated                  = toset(compact([for network in var.networks: !network.routed ? network.name : ""]))
  
  # A list of network names where DHCP feature is required
  dhcp                      = toset(compact([for network in var.networks: network.dhcp.end_range != "" ? network.name : ""]))
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
  
    dns1                    = contains(local.dhcp, each.value) ? try(local.networks[each.value].dhcp.dns[0], "") : "0.0.0.0"
    dns2                    = contains(local.dhcp, each.value) ? try(local.networks[each.value].dhcp.dns[1], "") : "0.0.0.0"
  
    dynamic "dhcp_pool" {
      for_each              = tolist(contains(local.dhcp, each.value) ? [local.networks[each.value].dhcp] : [])
      
      content {
        start_address       = coalesce(dhcp_pool.value.start_range, cidrhost(local.networks[each.value].network, 2))
        end_address         = dhcp_pool.value.end_range
      }
    }
}

resource "vcd_network_isolated" "isolated" {
  for_each                  = local.isolated
    
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    
    name                    = each.value
    description             = local.networks[each.value].description
      
    gateway                 = cidrhost(local.networks[each.value].network, 1)
    netmask                 = cidrnetmask(local.networks[each.value].network)
}
