var C = C || (function (undefined){
    
    var C = {
        what: "controller of route collections and items",
        version: "0.1.0"
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
        this.sort_result = [];
        this.current_order = 0;
        this.current_pos = undefined;

        this.pushAll(el);
        this.updateDistance();
    }

    Collection.prototype = {

        constructor: Collection,

        sort_by: function(key) {
            var map = [];
            for (var i in this.orderList) {
                map.push({
                    index: i,
                    value: this.orderList[i].info[key]
                });
            }
            map.sort(this.compare_int);
            console.log(map);
            for (var j in map)
                this.sort_result.push(this.orderList[map[j].index]);
            this.updateDOM();
        },

        updateDOM: function() {
            if (!this.sort_result)
                return;
            this.el.children().detach();
            console.log(this.sort_result);
            for (var i in this.sort_result) {
                this.sort_result[i].el.appendTo(this.el);
            }
            this.sort_result = [];
        },

        compare_int: function(a, b) {
            return a.value - b.value;
        },

        filter: function(clause){ // freq_pattern; distance
            this.el.children().detach();
            for (var i in this.hash) {
                if (clause(this.hash[i].info))
                    this.hash[i].el.appendTo(this.el);
            }
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
                    var pos_s = new BMap.Point(
                        r.info["lng_s hidden"],r.info["lat_s hidden"]);
                    var pos_d = new BMap.Point(
                        r.info["lng_d hidden"],r.info["lat_d hidden"]);
                    r.setDistance(map.getDistance(point, pos_s), map.getDistance(point, pos_d));
                }
            });
        },

        pushAll: function(el) {
            var self = this;
            el.children().each(function() {
                self.add($(this));
            });
            for (var a in this.hash)
                this.orderList.push(this.hash[a]);
        },

        add: function(el){
            var id = el.attr('id');
            var newItem = new Route(el);
            newItem.parent = this;

            if (this.hash[id])
                return;
            this.hash[id] = newItem;
        },

        remove: function(el) {
            var parent = this;
            var id = el.attr('id');
            if (this.hash[id])
                delete this.hash[id];
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
                self.info[$(el).attr('class')] = $(el).find('p').html().trim();
            });
        },
        setDistance: function(src, des) {
            this.info['dist_s'] = src;
            this.info['dist_d'] = des;
            this.info['dist_w'] = src + des; // weighted distance
        }
        
    };

    // ================> Expose <=================== //
    C.Collection = Collection;
    C.Route = Route;
    return C;
    // ============================================= //

}());


// ================ page controller =============== //
var R = {
    from_str: "",
    to_str: "",
    data: "",
    copy2overlay: {
        '#new_from': '#from',
        '#new_to': '#to',
        '#request_from': '#from',
        '#request_to': '#to',
        '#new_lat_s': '#route_lat_s',
        '#new_lng_s': '#route_lng_s',
        '#new_lat_d': '#route_lat_d',
        '#new_lng_d': '#route_lng_d',
        '#request_lat_s': '#route_lat_s',
        '#request_lng_s': '#route_lng_s',
        '#request_lat_d': '#route_lat_d',
        '#request_lng_d': '#route_lng_d'
    },

    init: function() {
        this.bind_event();
        this.ajaxRequest('GET', '/conversations');
        this.map_h = new bdmap("map_container_home", "from", "to");
        this.filter = $("#filter_wrapper").detach();

        // this.record_clickable();

        if ( document.title == "Dashboard") {
            this.map_1 = new bdmap("map_container_1");
            this.map_2 = new bdmap("map_container_2");
            this.map_3 = new bdmap("map_container_3");
            F.init();
        } else if ( document.title == "Home" ) {
            var map = this.map_h;
            map.locate_me(function(point, Map) {
                Map.getAddress(point);
                Map.r.handleGPS(Map);
            });
        }
        
        this.ajaxRequest('GET', '/conversations');
    },

    setMap: function() {

    },

    bindTable: function(table) {
        this.table = new C.Collection($(table));
        this.setFilter();
    },

    setFilter: function() {
        var list = this.table;
        var sort_dist_s = $('#optionsRadio2').click(function() {
            list.sort_by('dist_s');
        });
        var sort_dist_w = $('#optionsRadio1').click(function() {
            list.sort_by('dist_w');
        });
        var sort_price = $('#optionsRadio4').click(function() {
            list.sort_by('price');
        });
        var sort_tspan = $('#optionsRadio5').click(function() {
            list.sort_by('t_length');
        });
        var ckbox_regular = $('#checkbox2').click(function() {
            if ($(this).parent().hasClass('checked')) {
                list.filter(function() {
                    return true;
                });
            } else {
                list.filter(function(info) {
                    if (info['freq_single'])
                        return true;
                    else
                        return false;
                });
                
            }
        });
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
        for (var i in this.copy2overlay)
            $(i).val($(this.copy2overlay[i]).val());
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
                $("#route_lng_s").prop("value", point.lng);
                $("#route_lat_s").prop("value", point.lat);
                // this.data = point.lng + ":" + point.lat;
            }
            if ( s == "des") {
                $("#route_lng_d").prop("value", point.lng);
                $("#route_lat_d").prop("value", point.lat);
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
        this.ajaxRequest('GET', '/routes');
    },

    backToSavedRoutes: function(){
        this.ajaxRequest('GET', '/fav_relations');
    },

    bind_event: function() {
        var that = this;
        $(window).scroll(function() {
            var t = $(window).scrollTop();
            if(t >= 50){
                $('.map_left').addClass('fixtop');
            }
            if (t < 50){
                $('.map_left').removeClass('fixtop');
            }
        });
        var self = this;
        $("li.new_search").click(function() {
            self.map_h.locate_me(function(point, Map) {
                Map.getAddress(point);
                Map.r.handleGPS(Map);
            });
        });
        $('#mailbox-btn').tooltip({ placement : 'right' }).click($.proxy(this.openOverlay('mailbox_sidebar_enabled'), this));
        $('.mailbox_sidebar_close').click($.proxy(this.closeOverlay('mailbox_sidebar_enabled'), this));
        $('.mailbox_sidebar_back').click($.proxy(this.backToConversations, this));
        $('#new_form_btn').click($.proxy(function(event) {
            event.preventDefault();
            this.updateOverlayInput();
            this.openOverlay('finishnew_overlay_enabled')();
        }, this));
        $('#new_search_btn').click(function() {
            $('#main_map').detach();
            self.filter.prependTo('#search_result_wrapper');
            $('.search_form').removeClass('center');
        });
        $('.finishnew_overlay_close').click($.proxy(this.closeOverlay('finishnew_overlay_enabled'), this));
        $('.route_detail_overlay_close').click($.proxy(this.closeOverlay('route_detail_overlay_enabled'), this));
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
    this.map.centerAndZoom(initPoint, 15);
    this.map.enableContinuousZoom();
    this.map.enableScrollWheelZoom();

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
        this.map.centerAndZoom(initPoint, 15);
        this.map.enableContinuousZoom();
        this.map.enableScrollWheelZoom();
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

// ================ flat-ui ======================//
var F = {
    toggleHandler: function(toggle) {
        var toggle = toggle;
        var radio = $(toggle).find("input");

        var checkToggleState = function() {
            if (radio.eq(0).is(":checked")) {
                $(toggle).removeClass("toggle-off");
            } else {
                $(toggle).addClass("toggle-off");
            }
        };

        checkToggleState();

        radio.eq(0).click(function() {
            $(toggle).toggleClass("toggle-off");
        });

        radio.eq(1).click(function() {
            $(toggle).toggleClass("toggle-off");
        });
    },

    setupLabel: function() {
        // Checkbox
        var checkBox = ".checkbox";
        var checkBoxInput = checkBox + " input[type='checkbox']";
        var checkBoxChecked = "checked";
        var checkBoxDisabled = "disabled";

        // Radio
        var radio = ".radio";
        var radioInput = radio + " input[type='radio']";
        var radioOn = "checked";
        var radioDisabled = "disabled";

        // Checkboxes
        if ($(checkBoxInput).length) {
            $(checkBox).each(function(){
                $(this).removeClass(checkBoxChecked);
            });
            $(checkBoxInput + ":checked").each(function(){
                $(this).parent(checkBox).addClass(checkBoxChecked);
            });
            $(checkBoxInput + ":disabled").each(function(){
                $(this).parent(checkBox).addClass(checkBoxDisabled);
            });
        }

        // Radios
        if ($(radioInput).length) {
            $(radio).each(function(){
                $(this).removeClass(radioOn);
            });
            $(radioInput + ":checked").each(function(){
                $(this).parent(radio).addClass(radioOn);
            });
            $(radioInput + ":disabled").each(function(){
                $(this).parent(radio).addClass(radioDisabled);
            });
        }
    },

    init: function() {
        var self = this;
        $("html").addClass("has-js");

        // First let's prepend icons (needed for effects)
        $(".checkbox, .radio").prepend("<span class='icon'></span><span class='icon-to-fade'></span>").parent().addClass('checked');

        $(".checkbox, .radio").click(function() {
            self.setupLabel();
        });
        this.setupLabel();
        $("#slider").slider({
            min: 1,
            max: 5,
            value: 2,
            orientation: "horizontal",
            range: "min"
        });
    }
};

R.init();