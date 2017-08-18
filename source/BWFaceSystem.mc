using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Time.Gregorian as Calendar;

class SystemField extends Ui.Drawable {

    var locX;
    var locY;

// 	var batterySize = [18,9];
// 	var messageSize = [12,7];
    var framePadding = 2;

    var w = 18;
    var h = 9;
    var wm = 12;
    var hm = 7;

	var btIconSize     = 6;
	var btIconPenWidth = 1;
	var btIconColor    = Gfx.COLOR_BLUE;

    function initialize(params){
        var dictionary = {
            :identifier => "SystemField"
        };
        Drawable.initialize(dictionary);
        locX = params.get(:x);
        locY = params.get(:y);
        w = params.get(:batteryWidth);
        h = params.get(:batteryHeight);
        wm = params.get(:messageWidth);
        hm = params.get(:messageHeight);
    }

    function draw(dc){
        var systemStats = Sys.getSystemStats();
        var battery     = systemStats.battery;
        var fbattery    =  battery.format("%d") + "%";

//        var wm = messageSize[0];
//        var w = batterySize[0];
//        var h = batterySize[1];
//        var hm = messageSize[1];
        var x = locX-w/2;
        var y = locY;

		var micon = Sys.getDeviceSettings().notificationCount>0;

        var fg = BWFace.getColor("ForegroundColor");
        dc.setColor(fg, Gfx.COLOR_TRANSPARENT);

        if (micon) {
            BWFace.messagesIcon(dc,x-wm/2, y, wm, hm);
            x += wm/2+4;
            x = x + btIconSize/2;
        }

         if (battery>50){
        	dc.setColor(fg, Gfx.COLOR_TRANSPARENT);
        }
        else if (battery>20){
        	dc.setColor(BWFace.getColor("BatteryWarnColor"), Gfx.COLOR_TRANSPARENT);
        }
        else {
        	dc.setColor(BWFace.getColor("BatteryLowColor"), Gfx.COLOR_TRANSPARENT);
        }

        dc.drawRectangle(x+w, y+h/3.0, 2, h/2.0-1);
        dc.drawRoundedRectangle(x, y, w, h, 2);
        dc.fillRoundedRectangle(x, y, w*battery/100, h, 2);

        var xp = x+w+framePadding;
        var yp = y+h/2-2;

        var color = Sys.getDeviceSettings().phoneConnected ? btIconColor: 0x303030;
        BWFace.phoneIcon(dc,
                     xp+btIconSize, y+h/2,
                     btIconSize, btIconPenWidth,
                     color,
                     Sys.getDeviceSettings().phoneConnected);
    }
}