using Toybox.Lang;
using Toybox.System;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.UserProfile as User;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Time as Time;
using Toybox.ActivityMonitor as ActivityMonitor;

module BWFace {

    var colorScheme = {
        0 => {
                    "BackgroundColor" => 0x000000,
                    "ForegroundColor" => 0xFFFFFF,
                    "HoursColor"      => 0xFFFFFF,
                    "TimeColonColor"  => 0xFFFFFF,
                    "MinutesColor"    => 0xFFFFFF,
                    "SurplusColor"    => 0x555555,
                    "ActivityColor"   => 0xA0A0A0,
                    "DeficitColor"    => 0xFFFFFF
                    },
        1 => {
                    "BackgroundColor" => 0xFFFFFF,
                    "ForegroundColor" => 0x000000,
                    "HoursColor"      => 0x000000,
                    "TimeColonColor"  => 0x000000,
                    "MinutesColor"    => 0x000000,
                    "SurplusColor"    => 0x555555,
                    "ActivityColor"   => 0xA0A0A0,
                    "DeficitColor"    => 0x000000
                    },
        2 => {
                    "BackgroundColor" => 0x000000,
                    "ForegroundColor" => 0xEFEFEF,
                    "HoursColor"      => 0xFFA500,
                    "TimeColonColor"  => 0xE0E0E0,
                    "MinutesColor"    => 0x32CD32,
                    "SurplusColor"    => 0x7F2400,
                    "ActivityColor"   => 0xD06900,
                    "DeficitColor"    => 0x247F00
                    }
    };

	function getProperty(key,default_value) {
		var v = App.getApp().getProperty(key);
		return v == null ? default_value : v;
	}

    function getColor(color){
        return colorScheme[getProperty("ColorScheme",0)][color];
    }

	function setProperty(key,value) {
		App.getApp().setProperty(key, value);
	}

	var partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );

	function decimals(n,scale){
		var t0=(n.toFloat())/1000.0;
		var t1=(n.toFloat())/1000.0;
		var fract = ((((t1 - n.toLong()/1000)*1000).toFloat())/scale.toFloat()).toLong();
		return [t0.toLong(),fract];
	}

	function decFields(value,delim,scale,prec){
		if (value==null) {
			return ["--",""];
		}
		if (value instanceof Lang.String){
			var index = value.find(":");
			if (index==null){
			    index = value.find(".");
			    if (index==null){
				    return [value,""];
				}
				index = 1;
			}
			var v0 = value.substring(0, index);
			var v1 = value.substring(index, value.length());
			return [v0,v1];
		}
		var dec  = decimals(value.toNumber(),scale);
		return [dec[0].toString(),delim+dec[1].format("%0"+prec+"d")];
	}

	function messagesIcon(dc, x, y, w, h){
	    var m = [[x,y], [x+w,y], [x+w,y+h], [x+w*2/3-1,y+h], [x+w*1/3-1,y+h+h/2], [x+w*1/3-1,y+h], [x,y+h]];
		dc.fillPolygon(m);
	}

	function phoneIcon(dc, _x, y, size, width, color, isConnected){
		var x = _x + size;

		dc.setPenWidth(width);

		dc.setColor(color, Gfx.COLOR_TRANSPARENT);

		if (isConnected){
			dc.drawLine(x-size/2-2, y-size/2-1, x+size/2, y+size/2);
			dc.drawLine(x-size/2-2, y+size/2+1, x+size/2, y-size/2);
			dc.drawLine(x-1, y+size, x-1, y-size);
			dc.drawLine(x-1, y+size, x+size/2, y+size/2-1);
			dc.drawLine(x-1, y-size, x+size/2, y-size/2+1);
		}
		else {
			dc.drawLine(x-size/2-1, y-size/2, x+size/2, y+size/2+1);
			dc.drawLine(x-size/2-1, y+size/2, x+size/2, y-size/2-1);
		}
	}

	 function bmr(){
    		var profile = User.getProfile();
    		var bmrvalue;
    		var today = Calendar.info(Time.now(), Time.FORMAT_LONG);
    		var w   = profile.weight;
    		var h   = profile.height;
    		var g   = profile.gender;
    		var birthYear = profile.birthYear;
    		if (birthYear<100) {
    		    // simulator
    			birthYear = 1900+birthYear;
    		}
    		var age = today.year - birthYear;

    		if (g == User.GENDER_FEMALE) {
    			bmrvalue = 655.0 + (9.6*w/1000.0) + (1.8*h) - (4.7*age);
    		}
    		else {
    			bmrvalue = 66 + (13.7*w/1000.0) + (5.0*h) - (6.8*age);
    		}
    		var af = getProperty("ActivityFactor",1).toFloat();
    		af = af == null ? 1 : af;
    		af = af < 1 ? 1 : af;
    		return bmrvalue * af ;
    }

    function bmrDiff(){
		var calories = ActivityMonitor.getInfo().calories;
		if (calories==null) {
		    return 0;
		}
		var userBmr = BWFace.bmr();
		return calories - userBmr;
    }

    function activityFactor(){
		var calories = ActivityMonitor.getInfo().calories;
		if (calories==null) {
		    return 0;
		}
        var userBmr = BWFace.bmr();
        if (userBmr==0){
            return 0;
        }
        return calories/userBmr;
    }
}