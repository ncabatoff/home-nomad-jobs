job "mediaserver" {
  datacenters = ["dc1"]
  type = "service"
  group "core" {
    count = 2
    constraint {
      distinct_hosts = true
    }
    task "minidlna" {
      driver = "docker"
      config {
        image = "geekduck/minidlna"
        network_mode = "host"
        port_map {
          http = "8200"
        }
        volumes = [
          "/tank/audio:/opt/Music",
          "/tank/video:/opt/Videos",
          "/tank/pics:/opt/Pictures",
          "/data/minidlna:/var/cache/minidlna"
        ]
      }
      resources {
        network {
          port "http" {
            static = "8200"
          }
        }
        memory = 250
      }
      service {
        name = "minidlna"
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
    task "bubbleupnp" {
      driver = "docker"
      config {
        image = "rwgrim/docker-bubbleupnpserver"
        network_mode = "host"
      }
      resources {
        network {
          port "http" {
            static = "58050"
          }
        }
      }
      service {
        name = "bubbleupnp"
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
