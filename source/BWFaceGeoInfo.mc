using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Activity as Activity;

class BWFaceGeoInfo
{
	function initialize(){}

    var altitude = null;

    function getLocation() {

		var actInfo  = Activity.getActivityInfo();

		if (actInfo == null ) {
			actInfo = Activity.getActivityInfo();
		}
		else if (actInfo.currentLocation == null ) {
			actInfo = Activity.getActivityInfo();
		}

        if(actInfo != null)
        {
            var deg = actInfo.currentLocation;
            if(deg != null)
            {
               var degArray = deg.toDegrees();
               BWFace.setProperty("CurrentLocation", degArray);
               return degArray;
            }
        }
        return BWFace.getProperty("CurrentLocation", null);
    }

    function getAltitude() {
    	var factor = 1;
    	if (Sys.getDeviceSettings().elevationUnits == Sys.UNIT_STATUTE){
    		factor = 3.28084;
    	}

		var actInfo  = Activity.getActivityInfo();

        if(actInfo != null) {
            altitude = actInfo.altitude == null ? altitude : actInfo.altitude;
        }
        if (altitude != null) {
			return Math.ceil(altitude * factor);
        }
        return altitude;
    }

    function dayOfTheYear()
    {
        var day = Calendar.info(Time.now(), Time.FORMAT_SHORT).day;
        var month = Calendar.info(Time.now(), Time.FORMAT_SHORT).month;
        var year = Calendar.info(Time.now(), Time.FORMAT_SHORT).year;

        var N1 = Math.floor(275 * month / 9);
        var N2 = Math.floor((month + 9) / 12);
        var N3 = (1 + Math.floor((year - 4 * Math.floor(year / 4) + 2) / 3));
        return N1 - (N2 * N3) + day - 30;
    }
    
    (:typecheck(false))
    function computeSunrise(sunrise)
    {

        /*Sunrise/Sunset Algorithm taken from
            http://www.edwilliams.org/sunrise_sunset_algorithm.htm
            inputs:
                day = day of the year
                sunrise = true for sunrise, false for sunset
            output:
                time of sunrise/sunset in hours */
		var location = getLocation();

		if (location == null) {
			return null;
		}

        var day = dayOfTheYear();

        var latitude = location[0];
        var longitude = location[1];

        var zenith = 90.83333333333333;
        var D2R = Math.PI / 180;
        var R2D = 180 / Math.PI;

        // convert the longitude to hour value and calculate an approximate time
        var lnHour = longitude / 15;
        var t;
        if (sunrise) {
            t = day + ((6 - lnHour) / 24);
        } else {
            t = day + ((18 - lnHour) / 24);
        }

        //calculate the Sun's mean anomaly
        var M = (0.9856 * t) - 3.289;

        //calculate the Sun's true longitude
        var L = M + (1.916 * Math.sin(M * D2R)) + (0.020 * Math.sin(2 * M * D2R)) + 282.634;
        if (L > 360) {
            L = L - 360;
        } else if (L < 0) {
            L = L + 360;
        }

        //calculate the Sun's right ascension
        var RA = R2D * Math.atan(0.91764 * Math.tan(L * D2R));
        if (RA > 360) {
            RA = RA - 360;
        } else if (RA < 0) {
            RA = RA + 360;
        }

        //right ascension value needs to be in the same qua
        var Lquadrant = (Math.floor(L / (90))) * 90;
        var RAquadrant = (Math.floor(RA / 90)) * 90;
        RA = RA + (Lquadrant - RAquadrant);

        //right ascension value needs to be converted into hours
        RA = RA / 15;

        //calculate the Sun's declination
        var sinDec = 0.39782 * Math.sin(L * D2R);
        var cosDec = Math.cos(Math.asin(sinDec));

        //calculate the Sun's local hour angle
        var cosH = (Math.cos(zenith * D2R) - (sinDec * Math.sin(latitude * D2R))) / (cosDec * Math.cos(latitude * D2R));
        var H;
        if (sunrise) {
            H = 360 - R2D * Math.acos(cosH);
        } else {
            H = R2D * Math.acos(cosH);
        }
        H = H / 15;

        //calculate local mean time of rising/setting
        var T = H + RA - (0.06571 * t) - 6.622;

        //adjust back to UTC
        var UT = T - lnHour;

        if (UT > 24) {
            UT = UT - 24;
        } else if (UT < 0) {
            UT = UT + 24;
        }

        //convert UT value to local time zone of latitude/longitude
        var clockTime = Sys.getClockTime();
        var localT = UT + clockTime.timeZoneOffset/3600;

        if (localT > 24) {
            localT = localT - 24;
        } else if (localT < 0) {
            localT = localT + 24;
        }

        //convert to Milliseconds
        return localT * 3600 * 1000;
    }
}
