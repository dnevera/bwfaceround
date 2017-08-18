using Toybox.System as Sys;
using Toybox.Math as Math;
using Toybox.Activity as Activity;
using Toybox.ActivityMonitor as Monitor;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;

enum {
	BW_Distance    = 0,
	BW_Steps       = 1,
	BW_Calories    = 2,
	BW_Seconds     = 3,
	BW_Sunrise     = 4,
	BW_Sunset      = 5,
	BW_Altitude    = 6,
	BW_HeartRate   = 7,
	BW_Temperature = 8,
	BW_Pressure    = 9,
	BW_PressureMmHg= 10,
	BW_PressurehPa = 1001, // NOTE: currently i can't read sys configuration
	BW_UserBMR     = 11,
	BW_ActivityFactor    = 12,
	BW_FloorsClimbed     = 13,
	BW_Elevation         = 14,
	BW_Climbed       = 15,
	BW_Speed         = 16,
	//BW_AverageSpeed  = 17,
	BW_Cadence         = 18,
	//BW_AverageCadence  = 19
	BW_SunriseSunset     = 1004
}

class BWFaceValue {

	var geoInfo;

	function initialize(){
		geoInfo = new BWFaceGeoInfo();
	}

	function info(id) {
		var dict = {:scale=>1,:delim=>"",:title=>"", :format=>"%d", :prec=>3};
		switch (id) {
			case BW_Distance: // distance
                if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE) {
                    dict[:title] = Ui.loadResource( Rez.Strings.DistanceMilesTitle ).toUpper();
                }
                else {
                    dict[:title] = Ui.loadResource( Rez.Strings.DistanceTitle ).toUpper();
                }
				dict[:scale] = 10;
				dict[:prec] = 2;
				dict[:delim] = ",";
				break;
			case BW_Steps:
				dict[:title] = Ui.loadResource( Rez.Strings.StepsTitle ).toUpper();
				break;
			case BW_Calories:
				dict[:title] = Ui.loadResource( Rez.Strings.CaloriesTitle ).toUpper();
				break;
			case BW_Seconds:
				dict[:title] = Ui.loadResource( Rez.Strings.SecondsTitle ).toUpper();
				break;
			case BW_Sunrise:
				dict[:title] =  Ui.loadResource( Rez.Strings.SunriseTitle ).toUpper();
				break;

			case BW_Sunset:
				dict[:title] =  Ui.loadResource( Rez.Strings.SunsetTitle ).toUpper();
				break;

			case BW_SunriseSunset:
				dict[:title] =  "";
				break;

			case BW_Altitude:
			    if (Sys.getDeviceSettings().elevationUnits == Sys.UNIT_STATUTE){
				    dict[:title] = Ui.loadResource( Rez.Strings.AltitudeFeetTitle ).toUpper();
				}
				else {
				    dict[:title] = Ui.loadResource( Rez.Strings.AltitudeTitle ).toUpper();
				}
				break;

			case BW_HeartRate:
				dict[:title] = Ui.loadResource( Rez.Strings.BPMTitle ).toUpper();
				break;

			case BW_Temperature:
                if (Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_STATUTE) {
                     dict[:title] = Ui.loadResource( Rez.Strings.TemperatureFahrTitle ).toUpper();
                }
                else {
                     dict[:title]= Ui.loadResource( Rez.Strings.TemperatureTitle ).toUpper();
                }
				break;

			case BW_Pressure:
				dict[:title] = Ui.loadResource( Rez.Strings.PressureTitle ).toUpper();
				break;

			case BW_PressurehPa:
				dict[:title] = Ui.loadResource( Rez.Strings.PressurehPaTitle ).toUpper();
				break;

			case BW_PressureMmHg:
				dict[:title] = Ui.loadResource( Rez.Strings.PressureMmHgTitle ).toUpper();
				break;

			case BW_UserBMR :
				dict[:title] = Ui.loadResource( Rez.Strings.UserBMRTitle ).toUpper();
				break;

			case BW_ActivityFactor :
				dict[:title] = Ui.loadResource( Rez.Strings.ActivityFactorTitle ).toUpper();
				dict[:scale] = 10;
				dict[:delim] = ",";

				break;
			case BW_FloorsClimbed :
				dict[:title] = Ui.loadResource( Rez.Strings.FloorsClimbedTitle ).toUpper();
				break;

			case BW_Climbed :
			    if (Sys.getDeviceSettings().elevationUnits == Sys.UNIT_STATUTE){
				    dict[:title] = Ui.loadResource( Rez.Strings.ClimbedFeetTitle ).toUpper();
				}
				else {
				    dict[:title] = Ui.loadResource(Rez.Strings.ClimbedTitle  ).toUpper();
				}
				break;

			case BW_Elevation :
                if (Sys.getDeviceSettings().elevationUnits == Sys.UNIT_STATUTE) {
                     dict[:title] = Ui.loadResource( Rez.Strings.ElevationFeetTitle ).toUpper();
                }
                else {
                     dict[:title]= Ui.loadResource( Rez.Strings.ElevationTitle ).toUpper();
                }
				break;

			case BW_Speed :
                if (Sys.getDeviceSettings().elevationUnits == Sys.UNIT_STATUTE) {
                     dict[:title] = Ui.loadResource( Rez.Strings.SpeedFeetTitle ).toUpper();
                }
                else {
                     dict[:title] = Ui.loadResource( Rez.Strings.SpeedTitle ).toUpper();
                }
				break;
			case BW_Cadence :
				dict[:title] = Ui.loadResource( Rez.Strings.CadenceTitle ).toUpper();
				break;
		}
		return dict;
	}

    function distanceFactor(){
        if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
		   return 1.609344;
		}
	    else {
	       return 1;
	   }
    }

	function value(id) {
		var value = 0;
		switch (id) {
			case BW_Distance: // distance
				value = Monitor.getInfo().distance;
				value = value == null ? "--" : value/100.0/distanceFactor();
				break;

			case BW_FloorsClimbed:
			    if (Toybox.ActivityMonitor.Info has :floorsClimbed) {
					value = Monitor.getInfo().floorsClimbed;
					value = value == null ? "--" : value.format("%.0f");
				}
				else {
					value = "--";
				}
				break;

			case BW_Climbed:
			    if (Toybox.ActivityMonitor.Info has :metersClimbed) {
					value = Monitor.getInfo().metersClimbed;
					value = value == null ? "--" : value/distanceFactor();
				}
				else {
					value = "--";
				}
				break;

			case BW_Steps:
				value = Monitor.getInfo().steps;
				value = value== null ? "--" : value;
				break;

			case BW_Calories:
				value = Monitor.getInfo().calories;
				break;

			case BW_Seconds:
				if (BWFace.partialUpdatesAllowed){
					value = Sys.getClockTime().sec;
					value = value== null ? "--" : value.format("%02.0f");
				}
				else {
					value = "--";
				}
				break;

			case BW_Sunrise:
				value = sunrise();
				break;

			case BW_Sunset:
				value = sunset();
				break;

			case BW_SunriseSunset:
				value = sunrise()+" "+sunset();
				break;

			case BW_Altitude:
				value = geoInfo.getAltitude();
				value = value == null ? "--" : value;
				break;

			case BW_HeartRate:

				value = Activity.getActivityInfo();

				if (value != null){
					value = value.currentHeartRate;
				}

				if (value == null){
					value = getHeartRateIterator();
					if  ( value != null ){
						value = value.next();
						value = value == null ? null : value.data;
			    	}
				}

				value = value == null ? "--" : value.format("%d");

				break;

			case BW_Temperature:
				value = temperature();
				break;
			case BW_Pressure:
				value =  pressure(0.001, "%.1f", 10);
				break;
			case BW_PressurehPa:
				value =  pressure(0.01, "%.2f", 100);
				break;
			case BW_PressureMmHg:
				value =  pressure(0.00750062, "%.1f", 10);
				break;

			case BW_UserBMR :
				value =  BWFace.bmr();
				break;

			case BW_ActivityFactor :
				var c = Monitor.getInfo().calories;
				if (c>0) {
					value =  (c/BWFace.bmr()*1000);

				}
				else {
					value = "--";
				}
				break;

			case BW_Elevation:
				var sensorIter = getElevationIterator();
				if  ( sensorIter != null ){
					value = sensorIter.next();
					value = value == null ? "--" : value.data == null ? "--" : value.data/distanceFactor();
		    	}
				else {
					value = "--";
				}
				break;

			case BW_Speed :
				value = Activity.getActivityInfo();

				value = value == null ? null : value.currentSpeed;

				if (value != null ) {
				    if (Sys.getDeviceSettings().distanceUnits == Sys.UNIT_STATUTE){
                        value =  Math.round(value*2.23694).format("%.1f");
				    }
				    else {
					    value =  Math.round(value*3.6).format("%.1f");
					 }
				}
				else {
					value = "--";
				}
				break;

            case BW_Cadence :
				value = Activity.getActivityInfo();
				if (value == null){
				    value = "--";
				}
				else {
                    value = value.currentCadence;
                    value = value == null ? "--" : value.format("%.0f");
				}
				break;
		}

		var inf = info(id);

		if (!(value instanceof Toybox.Lang.String)){
            value = BWFace.decFields(value,inf[:delim],inf[:scale],inf[:prec]);
            if (value[0].length()>=3){
                value[1] = value[0].substring(1, value[0].length())+value[1];
                value[0] = value[0].substring(0,1);
            }
            value.add(inf[:title]);
		}
		else {
		    switch(value.length()){
		        case 0:
	    	        value = ["--",""];
		        break;
		        case 1:
    		        value = [value,""];
		        break;
		        case 2:
    		        value = [value,""];
		        break;
		        case 3:
    		        value = [value.substring(0, 2),value.substring(2, 4)];
		        break;
		        case 4:
    		        value = [value.substring(0, 2),value.substring(2, 5)];
		        break;
		        default:
    		        value = [value.substring(0, 1), value.substring(1, value.length())];
		        break;
		    }
		    value.add(inf[:title]);
		}
		return value;
	}

    function toSysHour(hour){
        if (Sys.getDeviceSettings().is24Hour){
            return (Math.floor(hour).toLong() % 24).format("%02.0f");
        }
        else {
            var h = Math.floor(hour).toLong() % 12;
            if(h==0){
                h=12;
            }
            return h.format("%2.0f");
        }
    }

	function sunrise(){
	    var sunRise = geoInfo.computeSunrise(true);
	    if (sunRise==null) {
	    	return "--";
	    }
	    sunRise=sunRise/1000/60/60;
		var r = Lang.format("$1$:$2$", [toSysHour(sunRise), Math.floor((sunRise-Math.floor(sunRise))*60).format("%02.0f")]);
		return r;
	}

	function sunset(){
        var sunSet = geoInfo.computeSunrise(false);
	    if (sunSet==null) {
	    	return "--";
	    }
        sunSet=sunSet/1000/60/60;

        var r = Lang.format("$1$:$2$", [toSysHour(sunSet), Math.floor((sunSet-Math.floor(sunSet))*60).format("%02.0f")]);
		return r;
	}

	function pressure(factor, format, scale){
		var sensorIter =  getPressureIterator();
		if  ( sensorIter != null ){
			var n = sensorIter.next();
			if (n.data == null){
				return "--";
			}
			n = n.data;
			return (Math.round(n*factor*scale)/scale).format(format);
    	}
		else {
			return "--";
		}
	}

	function temperature(){
        var sensorIter =  getTemperatureIterator();
        if  ( sensorIter != null ){
            var value = sensorIter.next();
            if (value.data == null) {
                return "--";
            }
            value = value.data;
            if (Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_STATUTE) {
                value = value * 9/5 + 32;
            }
            return (Math.round(value)).format("%.0f");
        }
        else {
            return "--";
        }
	}

	function getPressureIterator() {
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getPressureHistory)) {
	        return Toybox.SensorHistory.getPressureHistory({:order=>SensorHistory.ORDER_NEWEST_FIRST,:period=>1});
	    }
	    return null;
	}

	function getTemperatureIterator() {
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getTemperatureHistory)) {
	        return Toybox.SensorHistory.getTemperatureHistory({:order=>SensorHistory.ORDER_NEWEST_FIRST,:period=>1});
	    }
	    return null;
	}

	function getHeartRateIterator() {
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
	        return Toybox.SensorHistory.getHeartRateHistory({:order=>SensorHistory.ORDER_NEWEST_FIRST,:period=>1});
	    }
	    return null;
	}

	function getElevationIterator() {
	    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
	        return Toybox.SensorHistory.getElevationHistory({:order=>SensorHistory.ORDER_NEWEST_FIRST,:period=>1});
	    }
	    return null;
	}

}