DASHBOARDS=cluster.json

%.json: %.jsonnet
	jsonnet -J /Users/ncc/src/github.com/grafana/grafonnet-lib/grafonnet $< -o $@

../dashboards.tgz: $(DASHBOARDS)
	tar zcf ../dashboards.tgz $(DASHBOARDS)

grafana:
	for i in $(DASHBOARDS); do ../bin/dashToCurl < $$i | curl -i -u admin:admin -H "Content-Type: application/json" -X POST http://grafana.service.dc1.consul:3000/api/dashboards/db -d @- ; done
