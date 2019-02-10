terraform {
  backend "consul" {
    config {
      path = "terraform"
    }
  }
}
