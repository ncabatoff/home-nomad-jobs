job "grafana" {
  datacenters = ["dc1"]
  type = "service"
  group "core" {
    task "grafana" {
      template {
        destination = "local/provisioning/datasources/prometheus.yml"
        data = <<EOH
          apiVersion: 1

          datasources:
          - name: Prometheus
            type: prometheus
            access: proxy
            orgId: 1
            url: http://192.168.2.154:9090
            isDefault: true
            version: 1
            editable: false
      EOH
      }
      template {
        destination = "local/provisioning/dashboards/dashboards.yml"
        data = <<EOH
          apiVersion: 1

          providers:
          - name: 'default'
            orgId: 1
            folder: ''
            type: file
            disableDeletion: false
            updateIntervalSeconds: 60
            editable: true
            options:
              path: /local/dashboards
      EOH
      }
      template {
        data = "{{ key \"grafana/dashboards/prometheus-stats\" }}"
        destination = "local/dashboards/prometheus2.json"
      }
      template {
        data = "{{ key \"grafana/dashboards/nomad-cluster\" }}"
        destination = "local/dashboards/nomad-cluster.json"
      }
      template {
        data = "{{ key \"grafana/dashboards/nomad-jobs\" }}"
        destination = "local/dashboards/nomad-jobs.json"
      }
      template {
        data = "{{ key \"grafana/dashboards/consul\" }}"
        destination = "local/dashboards/consuljson"
      }
      driver = "docker"
      config {
        image = "grafana/grafana:5.1.0"
        # Why use host network mode?  We could avoid it if we used a direct
        # datasource, instead of proxy, but then the user's browser would need
        # to be able to do Consul DNS resolution.
        network_mode = "host"
        port_map {
          http = "3000"
        }
        dns_servers = [
          "${attr.driver.docker.bridge_ip}"
        ]
      }
      env {
        GF_LOG_LEVEL = "DEBUG"
        GF_PATHS_PROVISIONING = "/local/provisioning"
      }
      resources {
        memory = 100
        network {
          port "http" {
            static = "3000"
          }
        }
      }
      service {
        name = "grafana"
        port = "http"
        check {
          type = "http"
          path = "/api/health"
          interval = "30s"
          timeout = "2s"
        }
      }
    }
  }
}
