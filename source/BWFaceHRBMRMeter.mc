using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Math as Math;

class BMRMeter extends Ui.Drawable {

    var width;
    function initialize(params) {
        var dictionary = {
            :identifier => "BMRMeter"
        };

        Drawable.initialize(dictionary);
        width = params.get(:width);
    }

    function draw(dc) {

        var scale = 1;
		var userBmr = BWFace.bmr();
		var calories = ActivityMonitor.getInfo().calories;
		var cl = calories - userBmr;
		var isDeficit =  cl>=0;
		var prcnt = (cl/userBmr).abs();

		var color = isDeficit ? BWFace.getProperty("ActivityColor",0xA0A0A0) :  BWFace.getProperty("SurplusColor",0xFFFFFF);

		cl = cl.abs();

        if (isDeficit){
            if (calories/userBmr > BWFace.getProperty("ActivityFactorThreshold", 1.5)) {
                color = BWFace.getProperty("DeficitColor",0xFFFFFF);
            }
        }

		if (isDeficit){
			scale = Math.floor(prcnt+1);

			if (scale > 1) {
				var ncl = calories - userBmr*scale;
				prcnt = (ncl/userBmr).abs()/scale;
			}
		}

		dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(width);

        var x = dc.getWidth().toFloat()/2;
        var y = dc.getHeight().toFloat()/2;
        var r = x-width/2;

		var start=90;
		var end;
		var dir;
		if (isDeficit) {
			end = start-360*prcnt.abs();
			dir = Gfx.ARC_CLOCKWISE;
		}
		else {
			end = 360 + start;
			start = 360-360*prcnt.abs()+start;
			dir =  Gfx.ARC_COUNTER_CLOCKWISE;
		}

        dc.drawArc(x, y, r+1, dir, start, end);

		dc.setPenWidth(1);
		var bg = BWFace.getProperty("BackgroundColor", 0x000000);
		dc.setColor(bg,  bg);
		dc.drawArc(x, y, r-width/2+1, dir, start+0.5, end+0.5);
    }
}
