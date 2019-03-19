local grafana = import "grafana.libsonnet";
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Cluster view",
    editable = true,    
)
.addPanel(
    singlestat.new('consuls up',
        valueName='current',
        sparklineShow=true,
        gaugeShow=true,
        gaugeMaxValue=3,
        colorValue=true,
        thresholds='2,3',
        colors=["#d44a3a", "rgba(237, 129, 40, 0.89)", "#299c46"],
    ).addTarget(
        prom.target('sum(up{job="consul-servers"})')
    ),
    gridPos={ x: 0, y: 0, w: 2, h: 4}
)
.addPanel(
    graphPanel.new(
        'raft: time for leader to contact followers',
        description="see [doc](https://www.consul.io/docs/agent/telemetry.html#leadership-changes)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=2000,
    ).addTarget(
        prom.target('consul_raft_leader_lastContact{quantile="0.99"}'),
    ),
    gridPos={ x: 0, y: 4, w: 8, h: 6}
)
.addPanel(
    graphPanel.new(
        'raft: transaction rate',
        span=6,
        fill=0,
    ).addTarget(
        prom.target('rate(consul_raft_apply[1m])'),
    ),
    gridPos={ x: 0, y: 10, w: 8, h: 6}
)

# consul_raft_replication_heartbeat_03b70f9d_6b08_d9c1_af28_62515baec52c{quantile="0.99"}
#

