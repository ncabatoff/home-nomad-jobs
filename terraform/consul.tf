provider "consul" {}

data "local_file" "dashboard-prometheus" {
  filename = "consul/prometheus.json"
}
data "local_file" "dashboard-nomad-cluster" {
  filename = "consul/nomad-cluster.json"
}
data "local_file" "dashboard-nomad-jobs" {
  filename = "consul/nomad-jobs.json"
}
data "local_file" "dashboard-consul" {
  filename = "consul/consul.json"
}

resource "consul_key_prefix" "grafana_dashboards" {
  path_prefix = "grafana/dashboards/"
  subkeys = {
    "prometheus-stats" = "${data.local_file.dashboard-prometheus.content}"
    "nomad-cluster" = "${data.local_file.dashboard-nomad-cluster.content}"
    "nomad-jobs" = "${data.local_file.dashboard-nomad-jobs.content}"
    "consul" = "${data.local_file.dashboard-consul.content}"
  }
}