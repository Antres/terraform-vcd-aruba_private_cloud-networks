resource "vcd_nsxv_snat" "nsxv-snat" {
  # If Gateway Edge is Advanced
  for_each                  = var.region.edge.advanced ? local.egress : []
  
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    edge_gateway            = var.region.edge.name
  
    network_type            = "ext"
    network_name            = var.region.edge.external_network[0].name

    original_address        = local.networks[each.value.name].network
    translated_address      = var.region.edge.default_external_network_ip
}
