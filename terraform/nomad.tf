provider "nomad" {
  address = "http://nomad.service.dc1.consul:4646"
}

resource "nomad_job" "mediaserver" {
  jobspec = "${file("nomad/mediaserver.hcl")}"
}

resource "nomad_job" "grafana" {
  jobspec = "${data.template_file.grafana_hcl.rendered}"
}

data "template_file" "grafana_hcl" {
  template = "${file("nomad/grafana.hcl")}"
  vars = {
    dashboard_checksum = "${md5(data.local_file.dashboards.content)}"
  }
}
