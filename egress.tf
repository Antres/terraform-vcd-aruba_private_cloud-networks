resource "vcd_nsxv_snat" "nsxv-snat" {
  # If Gateway Edge is Advanced
  #count                     = var.region.edge.advanced ? length(local.egress) : 0
  for_each                   = tomap(var.region.edge.advanced ? local.egress : {})
  
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    edge_gateway            = var.region.edge.name
  
    description             = "Egress SNAT rule ${local.egress[each.value.name].name}"
  
    network_type            = "ext"
    network_name            = tolist(var.region.edge.external_network)[0].name

    original_address        = local.networks[each.value.name].network
    translated_address      = coalesce(each.value.egress.with_address, var.region.edge.default_external_network_ip)
  
    depends_on = [ vcd_network_routed.roueted-dhcp, vcd_network_routed.roueted-nodhcp ]
}
