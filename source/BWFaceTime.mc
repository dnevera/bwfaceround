using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;

module BWTime {
   function current(){

        var clockTime = Sys.getClockTime();
        var hour = clockTime.hour;

        var times = ["0","0", App.getApp().getProperty("UseMilitaryFormat") ? "" : ":", hour >= 12 ? "P" : "A", "M", "0", "0"];

        if (Sys.getDeviceSettings().is24Hour){
            var s = (hour % 24).format("%02.0f");
            times[0] = s.substring(0,1);
            times[1] = s.substring(1,2);
            times[3] = "";
            times[4] = "";
        }
        else {

            hour =  hour % 12;

            if(hour==0){
                hour=12;
            }
            if (hour>=10){
                var s = (hour % 24).format("%02.0f");
                times[0] = s.substring(0,1);
                times[1] = s.substring(1,2);
            }
            else {
                times[0] = "";
                times[1] = hour.format("%1.0f");
            }
            times[2] = "";
            //times[3] = "";
        }

        var min = clockTime.min;
//        var min = clockTime.sec;

        var m = min.format("%02.0f");
        times[5] = m.substring(0,1);
        times[6] = m.substring(1,2);

//        min = clockTime.sec % 24;
//        m = min.format("%02.0f");
//        times[0] = m.substring(0,1);
//        times[1] = m.substring(1,2);

        return times;
   }

    function today(){
        var clockTime = Sys.getClockTime();

        var t = Time.now();

        if (BWFace.getProperty("UseDayLightSavingTime", false)) {
            var offset = new Time.Duration(clockTime.dst);
            t=t.add(offset);
        }

        return  Calendar.info(t, Time.FORMAT_SHORT);
    }

//    protected function toSysHour(hour){
//        if (Sys.getDeviceSettings().is24Hour){
//            return (Math.floor(hour).toLong() % 24).format("%02.0f");
//        }
//        else {
//            var h = Math.floor(hour).toLong() % 12;
//            if(h==0){
//                h=12;
//            }
//            return h.format("%1.0f");
//        }
//   }
}
