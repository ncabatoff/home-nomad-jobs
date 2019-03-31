job "process-exporter" {
  datacenters = ["dc1"]
  type = "system"
  group "core" {
    task "process-exporter" {
      driver = "docker"
      config {
        image = "ncabatoff/process-exporter"
        args = [
          "-procfs", "/host/proc",
          "-config.path", "/local/process-exporter.yml",
        ]
        port_map {
          http = "9256"
        }
        volumes = [
          "/proc:/host/proc",
        ]
        privileged = true
      }
      template {
        destination = "local/process-exporter.yml"
        left_delimiter = "[["
        data = <<EOH
process_names:
  - name: "{{.Comm}}"
    cmdline:
    - '.+'
      EOH
      }
      resources {
        network {
          port "http" {
            static = "9256"
          }
        }
      }
      service {
        name = "process-exporter"
        tags = "prom"
        port = "http"
        check {
          type = "http"
          port = "http"
          path = "/metrics"
          interval = "30s"
          timeout = "1s"
        }
      }
    }
  }
}
