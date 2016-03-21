/**
 * Created by anvar on 7/18/15.
 */
(function ($) {

    var vars = {}, constants = {}, methods = {};

    constants.api = {
        visualization: "/api/v1/visualization/{0}",
        components: "/api/v1/components/{0}"
    };


    methods.init = function () {

        constants.topology_id = $('#stormwatch_topology_id').val();
        constants.graphite_server = $('#graphite_api_url').val();

        console.log(constants.graphite_server);

        methods.prepare_ui();

        methods.storm_get_topology_graph()
            .done(function () {
                methods.storm_get_topology_host_mapping()
                    .done(function () {
                        methods.visualize()
                    })
            })
    };

    methods.prepare_ui = function () {
        var myData = [
            {
                id: 1, label: "load.load.shortterm", isChecked : true
            },{
                id: 2, label: "memory.memory-used", isChecked : true
            },{
                id: 3, label: "memory.memory-free", isChecked : true
            },{
                id: 4, label: "memory.memory-buffered", isChecked : true
            },
        ];
        $("#controls-metrics-selector").dropdownCheckbox({
            data: myData,
            title: "chose metrics"
        });
    };

    //receive API response containing info about spouts and bolts and their connections
    methods.storm_get_topology_graph = function () {
        return $.ajax({
            type: 'get',
            url: constants.api.visualization.format(constants.topology_id),
            dataType: 'json',
            success: function (data) {

                vars.topology = {};
                vars.topology.spouts = [];
                vars.topology.bolts = [];
                vars.topology.spouts_and_bolts = [];

                for (var item in data) {
                    if (item !== '__system' && item !== '__acker') {
                        if (data[item][':type'] == 'spout') {
                            vars.topology.spouts[item] = data[item];
                        } else if (data[item][':type'] == 'bolt') {
                            vars.topology.bolts[item] = data[item];
                        }
                        vars.topology.spouts_and_bolts[item] = data[item];
                    }
                }
            }
        });
    };
    methods.storm_get_topology_host_mapping = function () {
        return $.ajax({
            type: 'get',
            url: constants.api.components.format(constants.topology_id),
            dataType: 'json',
            success: function (data) {
                vars.topology.hosts = data.hosts;
                vars.topology.host_mapping = data.components;
            }
        });
    }

    methods.visualize = function () {

        vars.width = $('#vis-graph').width();

        methods.draw_metrics();
        methods.draw_graph()        

    };

    methods.monitor = {};
    methods.monitor_utils = {};

    methods.monitor_utils.get_slot_entry_y = function (slot_id) {
        return $('#{0}'.format(slot_id)).position().top +
            $("#{0} .horizon".format(slot_id)).position().top +
            $('#' + slot_id + ' .horizon').height() / 2;
    };
    methods.monitor_utils.render = function (r, n) {
        var set = r.set().push(
            r.rect(n.point[0] - 30, n.point[1] - 13, 70, 44).attr({
                "fill": "#feb",
                r: "12px",
                "stroke-width": n.distance == 0 ? "3px" : "1px"
            })).push(
            r.text(n.point[0], n.point[1] + 10, (n.label || n.id))
        );
        return set;
    }


    methods.monitor.add_slot = function (horizon, slot_id, metrics, context, draw_axis) {
        if (!$('#slot-' + slot_id).length) {
            $('#vis-monitor').append("<div class='monitor-slot' id='slot-" + slot_id + "'></div>");
            $('#vis-monitor').append("<p class='monitor-slot-label'>" + slot_id + "</p>");
        }
        d3.select("#slot-" + slot_id).call(function (div) {
            if (draw_axis) {
                div.append("div")
                    .attr("class", "axis")
                    .call(context.axis().orient("top"));
            }
            div.selectAll(".horizon")
                .data(metrics)
                .enter().append("div")
                .attr("class", "horizon")                
                .call(horizon);

            div.append("div")
                .attr("class", "rule")
                .call(context.rule());
        });
    };

    methods.draw_metrics = function () {

        var context = cubism.context()
            .serverDelay(3e3)
            .clientDelay(1e3)
            .step(1e3)
            .size(vars.width);

        var graphite = context.graphite(constants.graphite_server);
        var horizon = context.horizon().metric(graphite.metric).height(30);

        var hostPostfix = '_ifi_uzh_ch';

        for (var host in(vars.topology.hosts)) {
            var metrics = [
                'sw.' + vars.topology.hosts[host] + hostPostfix + '.load.load.shortterm',
                'sw.' + vars.topology.hosts[host] + hostPostfix + '.memory.memory-used',
                'sw.' + vars.topology.hosts[host] + hostPostfix + '.memory.memory-free',
                'sw.' + vars.topology.hosts[host] + hostPostfix + '.memory.memory-buffered'
            ];
            methods.monitor.add_slot(horizon, vars.topology.hosts[host], metrics, context, (host == 0))
        }
    }

    methods.draw_graph = function () {
        var renderer, layouter, height = 600;

        vars.graph = new Graph();

        for (var spout in vars.topology.spouts) {
            vars.graph.addNode(spout, {label: "[spout]\n" + spout, render: methods.monitor_utils.render});
        }

        for (var bolt in vars.topology.bolts) {
            vars.graph.addNode(bolt, {label: "[bolt]\n" + bolt, render: methods.monitor_utils.render});
        }

        for (bolt in vars.topology.bolts) {
            var inputs = vars.topology.bolts[bolt][':inputs'];
            for (var input in inputs) {
                vars.graph.addEdge(inputs[input][':component'], bolt, {directed: true});
            }
        }


        for (var host in vars.topology.hosts) {
            var y = methods.monitor_utils.get_slot_entry_y('slot-' + vars.topology.hosts[host]);
            vars.graph.addNode("slot-entry-" + vars.topology.hosts[host], {}, true, {'x': vars.width, 'y': y});
        }

        for (item in vars.topology.host_mapping) {
            for (host in vars.topology.host_mapping[item]) {
                var executors_count = vars.topology.host_mapping[item][host];
                vars.graph.addEdge(item, "slot-entry-" + host, {
                    directed: false,
                    label: executors_count,
                    stroke: '#ddd',
                    fill: 'none'
                });

            }
        }

        var layouter = new Graph.Layout.Spring(vars.graph);
        renderer = new Graph.Renderer.Raphael('vis-graph', vars.graph, vars.width, height);
    }


    $(window).load(function () {       
        methods.init();
    });


})(jQuery);

//utils
if (!String.prototype.format) {
    String.prototype.format = function () {
        var args = arguments;
        return this.replace(/{(\d+)}/g, function (match, number) {
            return typeof args[number] != 'undefined'
                ? args[number]
                : match
                ;
        });
    };
}
