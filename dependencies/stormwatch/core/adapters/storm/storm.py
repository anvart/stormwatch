import httplib
import json

from django.conf import settings


class StormAdapter(object):

    storm_api_mock_mode = True
    #storm_api_url = "nimbus1:8080"
    storm_api_url = settings.STORM_UI_URL

    storm_api_summary = "/api/v1/cluster/summary"
    storm_api_topology = "/api/v1/topology/summary"
    storm_api_topology_details = "/api/v1/topology/{0}"
    storm_api_component_details = "/api/v1/topology/{0}/component/{1}"

    storm_api_supervisor = "/api/v1/supervisor/summary"

    storm_api_visualization = "/api/v1/topology/{0}/visualization"

    def cluster_summary_request(self):
        return self.make_request(self.storm_api_summary)

    def topology_summary_request(self):
        return self.make_request(self.storm_api_topology)

    def supervisor_summary_request(self):
        return self.make_request(self.storm_api_supervisor)

    def topology_visualization_request(self, topology_id):
        return self.make_request(self.storm_api_visualization.format(topology_id))

    def topology_components_request(self, topology_id):
        topology_details = self.make_request(self.storm_api_topology_details.format(topology_id))
        items = []
        spouts = topology_details['spouts']
        bolts = topology_details['bolts']

        for spout in spouts:
            items.append(spout['spoutId'])
        for bolt in bolts:
            items.append(bolt['boltId'])

        component_stat = {}
        hosts = []

        for item in items:
            component_stat[item] = {}
            res = self.make_request(self.storm_api_component_details.format(topology_id, item))
            for executor_stat in res['executorStats']:
                host = executor_stat['host']
                if host not in hosts:
                    hosts.append(host)
                if executor_stat['host'] not in component_stat[item]:
                    component_stat[item][host] = 1;
                else:
                    component_stat[item][host] += 1;

        return {'hosts': hosts, 'components' : component_stat}

    def make_request(self, param):
        if self.storm_api_mock_mode:
            param = param + '/'
        conn = httplib.HTTPConnection(self.storm_api_url)
        conn.request("GET", param)
        response = conn.getresponse()

        if response.status == 200:
            ret = json.loads(response.read())
            conn.close()
            return ret
        else:
            return None
