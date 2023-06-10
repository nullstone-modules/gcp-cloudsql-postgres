resource "google_project_iam_member" "service_agent" {
  depends_on = [google_project_service.service_networking]

  project = local.project_id
  member  = "serviceAccount:service-${local.project_number}@service-networking.iam.gserviceaccount.com"
  role    = "roles/servicenetworking.serviceAgent"
}

resource "google_compute_global_address" "db_private" {
  name          = local.resource_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = local.vpc_name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  depends_on = [google_project_iam_member.service_agent]

  network                 = data.google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_private.name]
}
