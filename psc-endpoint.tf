// Consumer-side Private Service Connect endpoint.
// When var.enable_psc is set, the Cloud SQL instance exposes a service attachment, but nothing can
// reach it until this VPC has a PSC endpoint (a reserved internal IP + forwarding rule) pointing at it,
// plus a DNS record so clients can resolve the instance by name.

// Reserve an internal IP in the private subnet for the PSC endpoint.
resource "google_compute_address" "psc" {
  count        = var.enable_psc ? 1 : 0
  name         = "${local.resource_name}-psc"
  region       = data.google_compute_subnetwork.private0.region
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.private0.self_link
  labels       = local.labels
}

// Forwarding rule that connects the reserved IP to the instance's PSC service attachment.
resource "google_compute_forwarding_rule" "psc" {
  count                 = var.enable_psc ? 1 : 0
  name                  = "${local.resource_name}-psc"
  region                = data.google_compute_subnetwork.private0.region
  network               = local.vpc_id
  ip_address            = google_compute_address.psc[0].self_link
  load_balancing_scheme = ""
  target                = google_sql_database_instance.this.psc_service_attachment_link

  depends_on = [google_project_service.compute]
}

// Register the endpoint IP in the network's internal DNS zone so apps connect via a stable hostname.
resource "google_dns_record_set" "psc" {
  count        = var.enable_psc ? 1 : 0
  managed_zone = local.internal_domain_zone_id
  name         = "${local.psc_dns_name}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.psc[0].address]

  depends_on = [google_project_service.dns]
}
