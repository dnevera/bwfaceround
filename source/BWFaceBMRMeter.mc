using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Math as Math;

class BMRMeter extends Ui.Drawable {

    var width;
    var locX;
    var locY;
    var scaleY;
    //var boxX;
    //var boxY;
    //var boxWidth;
    //var boxHeight;

    function initialize(params) {
        var dictionary = {
            :identifier => "BMRMeter"
        };

        Drawable.initialize(dictionary);
        width = params.get(:width);
        locX = params.get(:valueX);
        locY = params.get(:valueY);
        scaleY = params.get(:scaleY);
        //boxY = params.get(:boxY);
        //boxX = params.get(:boxX);
        //boxWidth = params.get(:boxWidth);
        //boxHeight = params.get(:boxHeight);
    }

    function draw(dc) {

        var scale = 1;
		var userBmr = BWFace.bmr();
		var calories = ActivityMonitor.getInfo().calories;
		var cl = calories - userBmr;
		var isDeficit =  cl>=0;
		var prcnt = (cl/userBmr).abs();

		var color = isDeficit ? BWFace.getColor("ActivityColor") :  BWFace.getColor("SurplusColor");

		cl = cl.abs();

        if (isDeficit){
            if (calories/userBmr > BWFace.getProperty("ActivityFactorThreshold", 1.5)) {
                color = BWFace.getColor("DeficitColor");
            }
        }

		if (isDeficit){
			scale = Math.floor(prcnt+1);

			if (scale > 1) {
				var ncl = calories - userBmr*scale;
				prcnt = (ncl/userBmr).abs()/scale;
			}
		}

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

		dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
		dc.setPenWidth(width);
        dc.drawArc(x, y, r+1, dir, start, end);

		dc.setPenWidth(1);

		var bg = BWFace.getColor("BackgroundColor");
		dc.setColor(bg,  bg);
		dc.drawArc(x, y, r-width/2+1, dir, start, end);

		//dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        //dc.drawRoundedRectangle(boxX, boxY, boxWidth, boxHeight, 2);

        var text   =  cl.format("%.0f");
		dc.setColor(BWFace.getColor("ForegroundColor"),  Gfx.COLOR_TRANSPARENT);
		//dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(locX, locY, BWFace.titleFont, text, Gfx.TEXT_JUSTIFY_CENTER);

        if (scale > 1) {
		    dc.setColor(bg,  bg);
		    dc.fillRectangle(x, 0, width, width);

		    dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
            dc.drawText(x, scaleY, BWFace.smallTitleFont, scale.format("%.0f"), Gfx.TEXT_JUSTIFY_CENTER);
            //dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
            //dc.drawCircle(x-1, 0, width + width/2);
        }
        else {
            dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
            dc.fillCircle(x, 0, width + width/3);
        }

        //var a = boxHeight+boxY;
        //var b = boxWidth/2;
        //var _sin = a/Math.sqrt(a*a+b*b);
        //var angle = Math.asin(_sin) * 180/Math.PI/2;

		//dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        //dc.drawArc(x, y, r-width/2+2, Gfx.ARC_CLOCKWISE, 90+angle+2, 90-angle-1);
        //dc.drawArc(x, y, r+width/2, Gfx.ARC_CLOCKWISE, 90+angle+1, 90-angle-1);


        //Sys.println("_sin = " + _sin + " angle = " + angle);
    }
}
