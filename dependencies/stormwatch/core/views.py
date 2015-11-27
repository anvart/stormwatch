from django.shortcuts import render
from .adapters.storm import storm

import json
from django.http import HttpResponse
from django.conf import settings


def index(request):    
    storm_adapter = storm.StormAdapter()
    context = {
        'cluster_summary': storm_adapter.cluster_summary_request(),
        'topology_summary': storm_adapter.topology_summary_request(),
        'supervisor_summary' : storm_adapter.supervisor_summary_request()
    }
    return render(request, 'index.html', context)

def topology_overview(request, topology_id):
    storm_adapter = storm.StormAdapter()
    context = {
        'topology_id': topology_id,
        'graphite_api_url' : settings.GRAPHITE_API_URL
    }

    return render(request, 'topology_overview.html', context)


# api calls
def visualization(request, topology_id):
    storm_adapter = storm.StormAdapter()
    response_data = storm_adapter.topology_visualization_request(topology_id)
    return HttpResponse(json.dumps(response_data), content_type="application/json")

def components(request, topology_id):
    storm_adapter = storm.StormAdapter()
    response_data = storm_adapter.topology_components_request(topology_id)
    return HttpResponse(json.dumps(response_data), content_type="application/json")
