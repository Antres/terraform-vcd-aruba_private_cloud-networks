resource "vcd_network_routed" "roueted-dhcp" {
  for_each                  = setintersection(local.routed, local.dhcp)
    
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    
    name                    = each.value
    description             = local.networks[each.value].description
      
    gateway                 = cidrhost(local.networks[each.value].network, 1)
    netmask                 = cidrnetmask(local.networks[each.value].network)
    edge_gateway            = var.region.edge.name
  
    dns1                    = coalesce(local.networks[each.value].dhcp.dns[0], local.defaults_dns[0])
    dns2                    = coalesce(local.networks[each.value].dhcp.dns[1], local.defaults_dns[1])
  
    dhcp_pool {
      start_address         = coalesce(local.networks[each.value].dhcp.start_range, cidrhost(local.networks[each.value].network, 2))
      end_address           = local.networks[each.value].dhcp.end_range
      max_lease_time        = coalesce(local.networks[each.value].dhcp.lease_time, local.defaults_lease_time)
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
  for_each                  = toset(local.isolated)
    
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    
    name                    = each.value
    description             = local.networks[each.value].description
      
    gateway                 = cidrhost(local.networks[each.value].network, 1)
    netmask                 = cidrnetmask(local.networks[each.value].network)
}
