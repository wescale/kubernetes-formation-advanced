resource "google_container_cluster" "training-cluster" {
  count              = "${var.MOD_COUNT}"
  name               = "training-cluster-${count.index}"
  zone               = "${var.MOD_REGION}-b"
  initial_node_count = 3

  min_master_version = "1.11.2-gke.18"
  node_version       = "1.11.2-gke.18"

  network    = "${google_compute_network.training_net.name}"
  subnetwork = "${google_compute_subnetwork.training_subnet.name}"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  network_policy {
    enabled = true
  }
}

resource "local_file" "client_certificate" {
  content  = "${element(google_container_cluster.training-cluster.*.master_auth.0.client_certificate, count.index)}"
  filename = "${path.cwd}/client-${count.index}.crt"
  count = "${var.MOD_COUNT}"
}

resource "local_file" "client_key" {
  content  = "${element(google_container_cluster.training-cluster.*.master_auth.0.client_key, count.index)}"
  filename = "${path.cwd}/client-${count.index}.key"
  count = "${var.MOD_COUNT}"
}

resource "local_file" "cluster_ca_certificate" {
  content  = "${element(google_container_cluster.training-cluster.*.master_auth.0.cluster_ca_certificate, count.index)}"
  filename = "${path.cwd}/ca-${count.index}.crt"
  count = "${var.MOD_COUNT}"
}
