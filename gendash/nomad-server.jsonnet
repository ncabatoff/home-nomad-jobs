local grafana = import "grafana.libsonnet";
local graphPanel = grafana.graphPanel;
local singlestat = grafana.singlestat;
local prom = grafana.prometheus;

grafana.dashboard.new(
    "Nomad Servers",
    editable = true,    
)
.addPanel(
    singlestat.new('nomad up',
        valueName='current',
        sparklineShow=true,
        gaugeShow=true,
        gaugeMaxValue=3,
        colorValue=true,
        thresholds='2,3',
        colors=["#d44a3a", "rgba(237, 129, 40, 0.89)", "#299c46"],
    ).addTarget(
        prom.target('sum(up{job="nomad-servers"})')
    ),
    gridPos={ x: 0, y: 0, w: 2, h: 4}
)
.addPanel(
    graphPanel.new(
        'raft: GC pausing over prev minute',
        description="Indicator of memory pressure. See [doc](https://www.nomadproject.io/docs/telemetry/index.html)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=500,
        legend_show=false,
   )
    .addTarget(
        prom.target('sum without(job) (rate(nomad_runtime_total_gc_pause_ns{job="nomad-servers"}[1m]))/1000000'),
    ),
    gridPos={ x: 8, y: 0, w: 8, h: 4}
)

.addPanel(
    graphPanel.new(
        'raft: rpc request rate',
        span=6,
        format='ops',
        fill=0,
        min=0,
        legend_show=false,
   )
    .addTarget(
        prom.target('sum without(job) (rate(nomad_nomad_rpc_request[1m]))'),
    ),
    gridPos={ x: 0, y: 4, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: rpc request error rate',
        span=6,
        format='ops',
        fill=0,
        min=0,
        legend_show=false,
    ).addTarget(
        prom.target('sum without(job) (rate(nomad_nomad_rpc_request_error[1m]))'),
    ),
    gridPos={ x: 8, y: 4, w: 8, h: 5}
)

.addPanel(
    graphPanel.new(
        'raft: time for leader to contact followers - 99th%',
        description="General indicator of Raft latency. See [doc](https://www.nomadproject.io/docs/telemetry/index.html)",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        max=2000,
        legend_show=false,
   )
    .addTarget(
        prom.target('sum without(job,quantile) (nomad_raft_leader_lastContact{quantile="0.99"})'),
    ),
    gridPos={ x: 0, y: 9, w: 8, h: 5}
)
.addPanel(
    graphPanel.new(
        'raft: append time - 99th%',
        description="General indicator of Raft latency.",
        span=6,
        format='dtdurationms',
        fill=0,
        min=0,
        legend_show=false,
    ).addTarget(
        prom.target('sum without(job,quantile) (nomad_raft_replication_appendEntries_rpc{quantile="0.99"})'),
    ),
    gridPos={ x: 8, y: 9, w: 8, h: 5}
)

