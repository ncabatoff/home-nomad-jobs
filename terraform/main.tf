terraform {
  backend "consul" {
    path = "terraform"
    address = "consul.service.dc1.consul:8500"
  }
}
