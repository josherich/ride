var C = C || (function (undefined){
    var C = {
        what: "controller of route collections and items",
        where: ""
    };
    setup();
    function setup(){
    }

    function log(){

    }

    function Collection(el){
        this.el = el;
        this.hash = {};
        this.orderHash = {};
        this.orderList = [];
        this.current_pos = undefined;
        this.pushAll(el);
        this.updateDistance();
    }

    Collection.prototype = {
        constructor: Collection,
        sort_by_distance: function(){// algorithm;distance;price;set_time;arrive_time;timespan
            var orderList = this.orderList;
            for (var route in this.hash) {
                console.log(orderList);
                var r = this.hash[route];
                var l = orderList.length;
                if (!orderList) {
                    orderList.push(r);
                    continue;
                }
                for (var i = 0; i < l; i++) {
                    if (r.distance >= orderList[i].distance)
                        continue;
                    else {
                        var j = l;
                        while (j > i) {
                            orderList[j] = orderList[j - 1];
                            j--;
                        }
                        orderList[i] = r;
                        break;
                    }
                }
                orderList.push(r);
            }
            console.log(orderList);
        },

        filter: function(clause){//freq_pattern;

        },
        
        animate: function(){

        },

        updateDistance: function() {
            var self = this;
            R.map_h.locate_me(function(point, Map) {
                var map = Map.map;
                self.current_pos = point;
                for (var route in self.hash) {
                    var r = self.hash[route];
                    var source_pos = new BMap.Point(
                        r.info["lng_s hidden"],r.info["lat_s hidden"]);
                    r.setDistance(map.getDistance(point, source_pos));
                    
                }
            });
        },

        pushAll: function(el) {
            var self = this;
            el.children().each(function() {
                self.add($(this));
            });
        },

        add: function(el){
            var id = el.attr('id');
            var newItem = new Route(el);
            newItem.parent = this;

            if (this.hash[id])
                return;

            this.hash[id] = newItem;
        },

        remove: function() {
            var parent = this;
            
            return this;
        }
    };

    // constructor of single route record
    function Route(el){
        this.parent = undefined;
        this.el = el;

        this.load(el);
    }

    Route.prototype = {

        constructor: Route,
        load: function(el){
            var info = el.find('.route_info');
            this.info = {};
            var self = this;
            info.children().each(function(i, el) {
                self.info[$(el).attr('class')] = $(el).html().trim();
            });
        },
        setDistance: function(d) {
            this.distance = d;
        }
        
    };

    // ================> Expose <===================
    C.Collection = Collection;
    C.Route = Route;
    return C;
    // =============================================

}());

var R = {
    from_str: "",
    to_str: "",
    data: "",

    init: function() {
        this.bind_event();
        this.ajaxRequest('GET', '/conversations');

        if ( document.title == "Dashboard") {
            this.map_d = new bdmap("map_container");
            this.map_h = new bdmap("map_container_home", "from", "to");
            this.record_clickable();
            this.manu_map();
            
        } else if ( document.title == "Home" ) {
            this.map_h = new bdmap("map_container_home", "from", "to");
            this.map_h.locate_me(function(point, map) {
                this.getAddress(point);
                this.r.handleGPS(map);
            });
        }
        
        this.ajaxRequest('GET', '/conversations');
    },

    manu_map: function() {
        var filter = null;
        var map = this.map_h;
        $("li.new_search").click(function() {
            filter = $("#filter_wrapper").detach();
            map.locate_me(function(point, Map) {
                Map.getAddress(point);
                Map.r.handleGPS(Map);
            });
        });
        $("li.my_routes, li.saved_routes, li.match_requests").click($.proxy(function() {
            if (filter) {
                filter.prependTo(".content .tab-content");
                filter = null;
                this.map_d.reset();
                this.record_clickable();
            }
        }, this));
    },

    record_clickable: function() {
        var list = $(".route_block, .requestor_list");
        var map = this.map_d;
        list.click( function(){
            from_str = $(this).find(".from").text();
            to_str = $(this).find(".to").text();
            map.driving.search( from_str, to_str );
        });
    },
    
    updateOverlayInput: function() {
        $('#new_from').val($('#from').val());
        $('#new_to').val($('#to').val());
        $('#request_from').val($('#from').val());
        $('#request_to').val($('#to').val());
        $('#new_lat_s').val($('#route_record_lat_s').val());
        $('#new_lng_s').val($('#route_record_lng_s').val());
        $('#new_lat_d').val($('#route_record_lat_d').val());
        $('#new_lng_d').val($('#route_record_lng_d').val());
        $('#request_lat_s').val($('#route_record_lat_s').val());
        $('#request_lng_s').val($('#route_record_lng_s').val());
        $('#request_lat_d').val($('#route_record_lat_d').val());
        $('#request_lng_d').val($('#route_record_lng_d').val());
    },

    handleGPS: function(map) {
        this.from_str = $("#from").val();
        this.to_str = $("#to").val();
        var myGeo = map.myGeo;
        if(this.from_str && this.to_str){
            map.driving.search(this.from_str, this.to_str);
            myGeo.getPoint(this.from_str, function(p){
                if (p) {
                    setGPS("src", p);
                } else {
                    alert("no GPS result for " + string);
                }
            }, "上海市");
            myGeo.getPoint(this.to_str, function(p){
                if (p) {
                    setGPS("des", p);
                } else {
                    alert("no GPS result for " + string);
                }
            }, "上海市");
        }
        

        function setGPS( s, point ) {
            if ( s == "src" ) {
                $("#route_record_lng_s").prop("value", point.lng);
                $("#route_record_lat_s").prop("value", point.lat);
                // this.data = point.lng + ":" + point.lat;
            }
            if ( s == "des") {
                $("#route_record_lng_d").prop("value", point.lng);
                $("#route_record_lat_d").prop("value", point.lat);
                // this.data += ";" + point.lng + ":" + point.lat;
                // $("#route_record_data").prop("value", data);
            } else {
                return;
            }
        }
    },

    openOverlay: function(overlay){
        return function() {
            $('body').addClass(overlay);
        };
        // jQuery('#feedbackForm input:submit').removeClass('disabled').removeAttr('disabled');
        // jQuery('#feedbackForm').fadeIn();
    },

    closeOverlay: function(overlay){
        return function() {
                $('body').removeClass(overlay);
        };
    },

    backToConversations: function(){
        this.ajaxRequest('GET', '/conversations');
    },

    backToMatchRequests: function(){
        this.ajaxRequest('GET', '/match_requests');
    },

    backToMyRoutes: function(){
        this.ajaxRequest('GET', '/route_records');
    },

    backToSavedRoutes: function(){
        this.ajaxRequest('GET', '/fav_relations');
    },

    bind_event: function() {
        // var that = this;
        // $(window).scroll(function() {
        //     var t = $(window).scrollTop();
        //     if(t >= 30){
        //         $('#main_map').addClass('fixtop');
        //     }
        //     if (t < 30){
        //         $('#main_map').removeClass('fixtop');
        //     }
        // });

        $('#mailbox-btn').tooltip({ placement : 'right' }).click($.proxy(this.openOverlay('mailbox_sidebar_enabled'), this));
        $('.mailbox_sidebar_close').click($.proxy(this.closeOverlay('mailbox_sidebar_enabled'), this));
        $('.mailbox_sidebar_back').click($.proxy(this.backToConversations, this));
        $('#new_form_btn').click($.proxy(function(event) {
            event.preventDefault();
            this.updateOverlayInput();
            this.openOverlay('finishnew_overlay_enabled')();
        }, this));

        $('.finishnew_overlay_close').click($.proxy(this.closeOverlay('finishnew_overlay_enabled'), this));
        
        $('#my_routes_back').click($.proxy(this.backToMyRoutes, this));
        $('#saved_routes_back').click($.proxy(this.backToSavedRoutes, this));
        $('#match_requests_back').click($.proxy(this.backToMatchRequests, this));

        $(".btn-group a").click(function() {
                $(this).siblings().removeClass("active");
                $(this).addClass("active");
            });
    },

    ajaxRequest: function(method, url) {
        $.ajax({
            type: method,
            url: url,
            success: function(data){
            }
        });
        return false;
    }
};

var bdmap = function(m, from, to){
    this.r = window.R;
    this.container = m;
    this.map = new BMap.Map(m);
    var initPoint = new BMap.Point(121.608477, 31.207143);
    this.map.enableContinuousZoom();
    this.map.enableScrollWheelZoom();
    this.map.centerAndZoom(initPoint, 15);

    this.driving = new BMap.DrivingRoute(this.map, {renderOptions:{map: this.map, autoViewport: true}});
    var traffic = new BMap.TrafficLayer();
    if(from)
        this.from = new BMap.Autocomplete({
            "input": from,
            "location": "上海市"
        });
    if(to)
        this.to = new BMap.Autocomplete({
            "input": to,
            "location": "上海市"
        });
    this.geolocation = new BMap.Geolocation();
    this.myGeo = new BMap.Geocoder();
    if(this.from && this.to)
        this.setInputCallback();
};

bdmap.prototype = {
    constructor: bdmap,
    reset: function(){
        this.map = new BMap.Map(this.container);
        var initPoint = new BMap.Point(121.608477, 31.207143);
        this.map.enableContinuousZoom();
        this.map.enableScrollWheelZoom();
        this.map.centerAndZoom(initPoint, 15);
    },
    locate_me: function(callback) {
        var that = this;
        var r = this.r;
        this.geolocation.getCurrentPosition(function(e){
            if(this.getStatus() == BMAP_STATUS_SUCCESS){
                var mk = new BMap.Marker(e.point);
                that.map.addOverlay(mk);
                that.map.panTo(e.point);
                var cor = e.point.lng + e.point.lat;
                // alert('您的位置：'+e.point.lng+','+e.point.lat);
                that.current_pos = e.point;
                callback(e.point, that);
            }
            else {
                alert('failed'+this.getStatus());
            }
        });
    },

    getAddress: function(point) {
        var gc = new BMap.Geocoder();
        var that = this;
        gc.getLocation(point, function(rs){
            var addComp = rs.addressComponents;
            if (that.from)
                that.from.setInputValue( addComp.city + addComp.district + addComp.street + addComp.streetNumber );

            // r.handleGPS(that);
            // alert("locate");
            // alert(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
        });
    },

    setInputCallback: function() {
        var that = this;
        var r = this.r;
        this.from.addEventListener("onconfirm", function(e) {
            r.handleGPS(that);
        });

        // trigger the route finder when dest input
        this.to.addEventListener("onconfirm", function(e) {
            var _value = e.item.value;
            // to_str = _value.province + _value.city + _value.district + _value.street + _value.business;
            r.handleGPS(that);
            // $("info").val(from + " 到 " + to);
        });
    }
};


R.init();
// var btn = $('#optionsRadio2').click(function() {
var list = new C.Collection($('#table_mine'));
    // console.log(list.current_pos);
console.log(list.hash['route_record_17'].info);
// });



