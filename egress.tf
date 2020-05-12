resource "vcd_nsxv_snat" "nsxv-snat" {
  # If Gateway Edge is Advanced
  for_each                   = tomap(var.region.edge.advanced ? local.egress : {})
  
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    edge_gateway            = var.region.edge.name
  
    description             = "Egress SNAT rule ${each.value.name}"
  
    network_type            = "ext"
    network_name            = tolist(var.region.edge.external_network)[0].name

    original_address        = local.networks[each.value.name].network
    translated_address      = coalesce(each.value.egress.with_address, var.region.edge.default_external_network_ip)
  
    depends_on = [ vcd_network_routed.roueted-dhcp, vcd_network_routed.roueted-nodhcp ]
}

resource "vcd_nsxv_firewall_rule" "nsxv-fw" {
  for_each                  = tomap(var.region.edge.advanced ? local.egress : {})
  
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    edge_gateway            = var.region.edge.name

  source {
    org_networks            = toset([each.value.name])
  }

  destination {
    ip_addresses            = toset([each.value.egress.to])
  }

  dynamic "service" {
    for_each                = toset(each.value.egress.ports)
    
    content {
      port                  = split("/", service.value)[0]
      protocol              = split("/", service.value)[1]
    }
  }
}
