job "dockerregistry" {
  datacenters = ["dc1"]
  type = "service"
  group "registry" {
    task "registry" {
      driver = "docker"
      config {
        image = "registry:2"
        port_map {
          http = "5000"
        }
      }
      resources {
        network {
          port "http" {
            static = "5000"
          }
        }
        memory = 50
      }
      service {
        name = "dockerregistry"
        port = "http"
        check {
          type = "http"
          port = "http"
          path = "/"
          interval = "30s"
          timeout = "1s"
        }
      }
    }
  }
}
