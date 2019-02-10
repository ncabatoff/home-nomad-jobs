provider "nomad" {
  address = "http://nomad.service.dc1.consul:4646"
}

resource "nomad_job" "mediaserver" {
  jobspec = "${file("nomad/mediaserver.hcl")}"
}

resource "nomad_job" "grafana" {
  jobspec = "${file("nomad/grafana.hcl")}"
}
