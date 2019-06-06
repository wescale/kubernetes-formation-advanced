resource "google_container_cluster" "training-cluster" {
  count              = "${var.nb-participants}"
  name               = "training-cluster-${count.index}"
  zone               = "${var.region}-b"
  initial_node_count = 3

  min_master_version = "1.12"
  node_version       = "1.12"

  network    = "${google_compute_network.training_net.name}"
  subnetwork = "${google_compute_subnetwork.training_subnet.name}"

  node_config {
    machine_type = "n1-standard-2"

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
  count    = "${var.nb-participants}"
}

resource "local_file" "client_key" {
  content  = "${element(google_container_cluster.training-cluster.*.master_auth.0.client_key, count.index)}"
  filename = "${path.cwd}/client-${count.index}.key"
  count    = "${var.nb-participants}"
}

resource "local_file" "cluster_ca_certificate" {
  content  = "${element(google_container_cluster.training-cluster.*.master_auth.0.cluster_ca_certificate, count.index)}"
  filename = "${path.cwd}/ca-${count.index}.crt"
  count    = "${var.nb-participants}"
}

output "cluster-endpoint" {
  value = "${join(",",google_container_cluster.training-cluster.*.endpoint)}"
}
