job "system-monitoring" {
  datacenters = ["dc1"]
  type = "system"
  group "core" {
    task "node_exporter" {
      driver = "docker"
      config {
        image = "quay.io/prometheus/node-exporter:v0.17.0"
        args = [
          "--path.rootfs", "/host",
          "--collector.supervisord",
          "--no-collector.nfs",
          "--no-collector.nfsd",
        ]
        port_map {
          http = "9100"
        }
        pid_mode = "host"
        privileged = true
        network_mode = "host"
        mounts = [
          {
            type = "bind"
            target = "/host"
            source = "/"
            readonly = true
            bind_options {
              propagation = "rslave"
            }
          }
        ]
      }
      resources {
        memory = 25
        network {
          port "http" {
            static = "9100"
          }
        }
      }
      service {
        name = "node-exporter"
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
        memory = 25
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
