var R = {

    from_str: "",

    to_str: "",

    data: "",

    init: function() {
        this.bdmap.init();
        this.bind_event();
        if ( document.title == "Dashboard") {
            this.bind_click_record();
            this.move_map();
            $("#map_left").hover(
                function() { $(this).width(700);},
                function() { $(this).width(240);}
            );
        } else if ( document.title == "Home" ) {
            this.setcallback();
            this.getInput();
            if(this.bdmap.locate_me()) {
                this.getInput();
                this.handleGPS( "src", from_str );
            }
        }
        this.ajaxRequest('GET', '/conversations');
    },

    move_map: function() {
        var map = $("#map_left");
        $(".messages, .profile").click( function() {
            map = map.detach();
        });
        $(".saved_routes, .home").click( function() {
            map.appendTo("#map_wrapper");
        });
    },

    bind_click_record: function() {
        var record = $("tbody tr:first");
        from_str = record.find(".from").text();
        to_str = record.find(".to").text();
        var table = $("table tr");
        var map = this.bdmap;
        table.click( function(){
            from_str = $(this).find(".from").text();
            to_str = $(this).find(".to").text();
            map.driving.search( from_str, to_str );
        });
    },
    
    updateInput: function(id_s,id_d) {

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

    handleGPS: function(type, str) {
        var myGeo = this.bdmap.myGeo;
        myGeo.getPoint(str, function(p){
            if (p) {
                setGPS( type, p );
            } else {
                alert("no GPS result for " + string);
            }
        }, "上海市");

        function setGPS( s, point ) {
            if ( s == "src" ) {
                $("#route_record_lng_s").prop("value", point.lng);
                $("#route_record_lat_s").prop("value", point.lat);
                this.data = point.lng + ":" + point.lat;
            }
            if ( s == "des") {
                $("#route_record_lng_d").prop("value", point.lng);
                $("#route_record_lat_d").prop("value", point.lat);
                this.data += ";" + point.lng + ":" + point.lat;
                $("#route_record_data").prop("value", data);
            } else {
                return;
            }
        }
    },

    setcallback: function() {
        var map = this.bdmap;
        var that = this;
        map.from.addEventListener("onconfirm", function(e) {
            that.getInput();
            that.handleGPS( "src", that.from_str );
        });

        // trigger the route finder when dest input
        map.to.addEventListener("onconfirm", function(e) {
            var _value = e.item.value;
            // to_str = _value.province + _value.city + _value.district + _value.street + _value.business;
            that.getInput();
            map.driving.search( that.from_str, that.to_str );

            that.handleGPS( "des", that.to_str );
            $("info").val(that.from_str + " 到 " + that.to_str);
        });
    },


    getInput: function() {
        this.from_str = $("#from").val();
        this.to_str = $("#to").val();
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


    bind_event: function() {
        // var that = this;
        $(window).scroll(function() {
            var t = $(window).scrollTop();
            if(t >= 30){
                $('#main_map').addClass('fixtop');
            }
            if (t < 30){
                $('#main_map').removeClass('fixtop');
            }
        });

        $('#mailbox-btn').tooltip({ placement : 'right' }).click($.proxy(this.openOverlay('mailbox_sidebar_enabled'), this));
        $('.mailbox_sidebar_close').click($.proxy(this.closeOverlay('mailbox_sidebar_enabled'), this));
        $('.mailbox_sidebar_back').click($.proxy(this.backToConversations, this));
        $('#new_form_btn').click($.proxy(function(event) {
            event.preventDefault();
            this.updateOverlayInput();
            this.openOverlay('finishnew_overlay_enabled')();
        }, this));
        $('.finishnew_overlay_close').click($.proxy(this.closeOverlay('finishnew_overlay_enabled'), this));
        $('#match_request_back').click($.proxy(this.backToMatchRequests, this));
    },

    ajaxRequest: function(method, url) {
        $.ajax({
            type: method,
            url: url,
            success: function(data){
            }
        });
        return false;
    },

    bdmap: {

        init: function() {
            this.map = new BMap.Map("map_container");
            var initPoint = new BMap.Point(121.608477, 31.207143);
            this.map.enableContinuousZoom();
            this.map.enableScrollWheelZoom();
            this.map.centerAndZoom(initPoint, 15);

            this.driving = new BMap.DrivingRoute(this.map, {renderOptions:{map: this.map, autoViewport: true}});
            var traffic = new BMap.TrafficLayer();
            // map.addTileLayer(traffic);

            this.from = new BMap.Autocomplete({
                "input": "from",
                "location": "上海市"
            });

            this.to = new BMap.Autocomplete({
                "input": "to",
                "location": "上海市"
            });

            this.geolocation = new BMap.Geolocation();
            this.myGeo = new BMap.Geocoder();

        },

        locate_me: function() {
            var that = this;
            this.geolocation.getCurrentPosition(function(r){
                if(this.getStatus() == BMAP_STATUS_SUCCESS){
                    var mk = new BMap.Marker(r.point);
                    that.map.addOverlay(mk);
                    that.map.panTo(r.point);
                    var cor = r.point.lng + r.point.lat;
                    // alert('您的位置：'+r.point.lng+','+r.point.lat);

                    //parse coordinate
                    var gc = new BMap.Geocoder();
                    gc.getLocation(r.point, function(rs){
                        var addComp = rs.addressComponents;
                        that.from.setInputValue( addComp.city + addComp.district + addComp.street + addComp.streetNumber );
                        return true;
                        // alert(addComp.province + ", " + addComp.city + ", " + addComp.district + ", " + addComp.street + ", " + addComp.streetNumber);
                    });
                }
                else {
                    alert('failed'+this.getStatus());
                }
            });
        }
    }
};
$(function() {
    R.init();
});