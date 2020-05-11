terraform {
  required_version          = "> 0.12.0"
  experiments               = []
}

locals {
  defaults_dns               = tolist(["8.8.8.8", "8.8.4.4"])
  defaults_lease_time        = 3600
  
  #A named map of networks. local.network[<NETWORK_NAME>] => <NETWORK>
  #networks                  = zipmap(tolist([for network in var.networks: network.name]), tolist(var.networks))
  networks                  = zipmap(var.networks[*].name, var.networks)
    
  # A list of network names with attribute "routed" is setted to TRUE
  routed                    = tolist(compact([for network in var.networks: network.routed ? network.name : ""]))
    
  # A list of network names with attribute "routed" is setted to FALSE
  isolated                  = compact([for network in var.networks: !network.routed ? network.name : ""])
  
  # A list of network names where DHCP feature is required
  dhcp                      = tolist(compact([for network in var.networks: network.dhcp.enable ? network.name : ""]))
}

resource "vcd_network_routed" "roueted-dhcp" {
  for_each                  = setintersection(local.routed, local.dhcp)
    
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    
    name                    = each.value
    description             = local.networks[each.value].description
      
    gateway                 = cidrhost(local.networks[each.value].network, 1)
    netmask                 = cidrnetmask(local.networks[each.value].network)
    edge_gateway            = var.region.edge.name
  
    dns1                    = lookup(local.networks[each.value].dhcp.dns, 0, local.defaults_dns[0])
    dns2                    = lookup(local.networks[each.value].dhcp.dns, 1, local.defaults_dns[1])
  
    dhcp_pool {
      start_address         = coalesce(local.networks[each.value].dhcp.start_range, cidrhost(local.networks[each.value].network, 2))
      end_address           = local.networks[each.value].dhcp.end_range
#     default_lease_time    = coalesce(local.networks[each.value].dhcp.lease_time, local.defaults.lease_time)
#     max_lease_time        = coalesce(local.networks[each.value].dhcp.lease_time, local.defaults.lease_time)
    }
}

resource "vcd_network_routed" "roueted-nodhcp" {
  for_each                  = setsubtract(local.routed, local.dhcp)
    
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    
    name                    = each.value
    description             = local.networks[each.value].description
      
    gateway                 = cidrhost(local.networks[each.value].network, 1)
    netmask                 = cidrnetmask(local.networks[each.value].network)
    edge_gateway            = var.region.edge.name
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
