provider "consul" {
  address = "consul.service.dc1.consul:8500"
}

data "local_file" "dashboards" {
  filename = "../dashboards.tgz"
}

resource "consul_keys" "grafana_dashboards" {
  key {
    path = "grafana/dashboards.tgz"
    value = "${data.local_file.dashboards.content}"
  }
}