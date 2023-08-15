resource "aws_service_discovery_private_dns_namespace" "dlwb" {
  name        = "dlwb"
  description = "Bus private discovery"
  vpc         = aws_vpc.main.id

  tags = var.tags
}

resource "aws_service_discovery_service" "bus" {
  name = "bus"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dlwb.id

    dns_records {
      ttl  = 300
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  tags = var.tags
}