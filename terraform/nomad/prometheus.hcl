job "prometheus" {
  datacenters = ["dc1"]
  type = "service"
  group "prometheus" {
    task "consul-exporter" {
      driver = "docker"
      config {
        image = "prom/consul-exporter:v0.4.0"
        args = [
          "--consul.timeout=1s",
          "--consul.server=${attr.driver.docker.bridge_ip}:8500",
        ]
        port_map {
          http = "9107"
        }
      }
      resources {
        network {
          port "http" {
            static = "9107"
          }
        }
        memory = 50
      }
      service {
        name = "consul-exporter"
        port = "http"
        # We don't really need to tag/publish this for scraping since we'll use
        # our sibling Prometheus to scrape us, and there's no point in relying on
        # Consul to discover a service for monitoring Consul.  Besides if we
        # publish it it'll get triple-scraped by our HA prometheus instances.
        # tags = ["prom"]
        check {
          type = "http"
          port = "http"
          path = "/"
          interval = "30s"
          timeout = "1s"
        }
      }
    }
    task "prometheus" {
      template {
        destination = "local/prometheus.yml"
        data = <<EOH
global:
  scrape_interval: "15s"

scrape_configs:
- job_name: prometheus-local
  static_configs:
  - targets: ['127.0.0.1:9090']

- job_name: consul_exporter
  static_configs:
  - targets: ['{{ env "NOMAD_ADDR_consul_exporter_http" }}']

- job_name: node_exporter-core
  static_configs:
  - targets: ['192.168.3.51:9100', '192.168.3.52:9100', '192.168.3.53:9100']

- job_name: process-exporter-core
  static_configs:
  - targets: ['192.168.3.51:9256', '192.168.3.52:9256', '192.168.3.53:9256']

- job_name: raspberrypi_exporter
  metrics_path: /metrics/raspberrypi_exporter
  static_configs:
  - targets: ['192.168.3.51:9661', '192.168.3.52:9661', '192.168.3.53:9661']

- job_name: consul-servers
  metrics_path: /v1/agent/metrics
  params:
    format:
    - prometheus
  static_configs:
  - targets: ['192.168.3.51:8500', '192.168.3.52:8500', '192.168.3.53:8500']
  # See https://github.com/hashicorp/consul/issues/4450
  metric_relabel_configs:
  - source_labels: [__name__]
    regex: 'consul_raft_replication_(appendEntries_rpc|appendEntries_logs|heartbeat|installSnapshot)_((\w){36})((_sum)|(_count))?'
    target_label: raft_id
    replacement: '${2}'
  - source_labels: [__name__]
    regex: 'consul_raft_replication_(appendEntries_rpc|appendEntries_logs|heartbeat|installSnapshot)_((\w){36})((_sum)|(_count))?'
    target_label: __name__
    replacement: 'consul_raft_replication_${1}${4}'

- job_name: nomad-servers
  metrics_path: /v1/metrics
  params:
    format:
    - prometheus
  static_configs:
  - targets: ['192.168.3.51:4646', '192.168.3.52:4646', '192.168.3.53:4646']
  metric_relabel_configs:
  - source_labels: [__name__]
    regex: 'nomad_raft_replication_(appendEntries_rpc|appendEntries_logs|heartbeat)_([^:]+:\d+)(_sum|_count)?'
    target_label: peer_instance
    replacement: '${2}'
  - source_labels: [__name__]
    regex: 'nomad_raft_replication_(appendEntries_rpc|appendEntries_logs|heartbeat)_([^:]+:\d+)(_sum|_count)?'
    target_label: __name__
    replacement: 'nomad_raft_replication_${1}${3}'

- job_name: consul-services
  consul_sd_configs:
  - server: {{ env "attr.driver.docker.bridge_ip" }}:8500
  relabel_configs:
  - action: keep
    regex: .*,prom,.*
    source_labels:
    - __meta_consul_tags
  - source_labels:
    - __meta_consul_service
    target_label: job
  - source_labels:
    - __meta_consul_service
    target_label: job
    # Consul won't let us register names with underscores, but dashboards may
    # assume the name node_exporter.  Fix on ingestion.
    regex: node-exporter
    replacement: node_exporter

- job_name: nomad-clients
  consul_sd_configs:
  - server: {{ env "attr.driver.docker.bridge_ip" }}:8500
    services:
    - nomad-client
  metrics_path: /v1/metrics
  params:
    format:
    - prometheus
  relabel_configs:
  - action: keep
    regex: (.*)http(.*)
    source_labels:
    - __meta_consul_tags

- job_name: consul-clients
  consul_sd_configs:
  - server: {{ env "attr.driver.docker.bridge_ip" }}:8500
    services:
    - consul-client
  metrics_path: /v1/agent/metrics
  params:
    format:
    - prometheus

      EOH
      }
      driver = "docker"
      config {
        image = "prom/prometheus:v2.8.1"
        args = ["--config.file=/local/prometheus.yml"]
        port_map {
          http = "9090"
        }
      }
      resources {
        network {
          port "http" {
            static = "9090"
          }
        }
        memory = 500
      }
      service {
        name = "prometheus"
        port = "http"
        tags = ["prom", "primary"]
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
