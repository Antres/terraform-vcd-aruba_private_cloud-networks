resource "vcd_nsxv_snat" "nsxv-snat" {
  # If Gateway Edge is Advanced
  count                     = var.region.edge.advanced ? length(local.egress) : 0
  
    org                     = var.region.vdc.org
    vdc                     = var.region.vdc.name
    edge_gateway            = var.region.edge.name
  
    description             = "Egress SNAT rule ${local.egress[count.index].name}"
  
    network_type            = "ext"
    network_name            = tolist(var.region.edge.external_network)[0].name

    original_address        = local.networks[local.egress[count.index].name].network
    translated_address      = coalesce(local.egress[count.index].egress.with_address, var.region.edge.default_external_network_ip)
}
