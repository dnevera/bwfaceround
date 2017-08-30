using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Time.Gregorian as Calendar;

class AFGraph extends Ui.Drawable {

    var locX;
    var locY;
    var height;
    var barWidth;
    var afTextX;
    var afTextY;

    function initialize(params) {
        var dictionary = {
            :identifier => "AFGraph"
        };

        Drawable.initialize(dictionary);
        locX = params.get(:x);
        locY = params.get(:y);
        afTextX = params.get(:afTextX);
        afTextY = params.get(:afTextY);
        height = params.get(:height);
        barWidth = params.get(:barWidth);
    }

    function draw(dc) {
        graphsField(dc,locX,locY, height);
    }

     function graphsField(dc,locX,locY, height) {

        var padding = 2;
        var hist = ActivityMonitor.getHistory();
        var calories = ActivityMonitor.getInfo().calories;

        var colSize = dc.getTextDimensions("W", BWFace.smallTitleFont);
        var w      = (barWidth+padding/2) * 2;
        var offset = w/2+padding/2;

        var count;
        var start;
        var start0 = 8;
        var shift;

        count = 8;
        start = hist.size()-1;
        shift = barWidth/2;

        var x0 = locX - (offset)*count/2 + shift;
        var y = locY;
        var x = x0;
        var ty = y;

        var bg = BWFace.getColor("BackgroundColor");
        var fg = BWFace.getColor("ForegroundColor");

        dc.setColor(fg,  Gfx.COLOR_TRANSPARENT);
        if (hist.size()==0){
            x +=  offset;
            for (var i = start0-1; i>=2; i--){
                var m = new Time.Moment(Time.today().value()-3600*24*i);
                var t = Calendar.info(m, Time.FORMAT_MEDIUM);
                dc.drawText(x, ty, BWFace.smallTitleFont, t.day_of_week.toString().substring(0, 1), Gfx.TEXT_JUSTIFY_CENTER);
                dc.fillRectangle(x-barWidth/2, y-1, w/2, 1);
                x +=  offset;
            }
            return;
        }

        var min0 = 100000;
        var max0 = 0.1;

        x = x0+padding/2;
        dc.setColor(fg,  Gfx.COLOR_TRANSPARENT);

        for (var i = start; i>=0; i--){
            if (hist[i].calories<min0) { min0 = hist[i].calories; }
            if (hist[i].calories>max0) { max0 = hist[i].calories; }

            var t = Calendar.info(hist[i].startOfDay, Time.FORMAT_MEDIUM);
            var vd =  t.day_of_week.toString().substring(0, 1);
            if (i <= start-1 && i>=0){
                dc.drawText(x, ty, BWFace.smallTitleFont, vd, Gfx.TEXT_JUSTIFY_CENTER);
            }
            x +=  offset;
        }

        if (calories<min0) { min0 = calories; }
        if (calories>max0) { max0 = calories; }

        var threshold = BWFace.getProperty("ActivityFactorThreshold", 1.5);

        var bmr = BWFace.bmr();

        x = x0-barWidth/2;
        var avrg = 0;
        var avrgAf = 0;
        var avrgCount = 0;
        var color;
        for (var i = start; i>=0; i--){
            var af = hist[i].calories/bmr;
            avrgAf += af;
            var h = height * hist[i].calories/max0;
            if (af<1){
                color = BWFace.getColor("SurplusColor");
            }
            else if (af>=threshold) {
                color = BWFace.getColor("DeficitColor");
            }
            else {
                color = BWFace.getColor("ActivityColor");
            }
            dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
            dc.fillRectangle(x, y-h, w/2, h);

            x +=  offset;
            avrg += h;
            avrgCount += 1;
        }

        var af = calories/bmr;
        avrgAf += calories/bmr;
        var h = height * calories/max0;
        avrg += h;

        avrgCount += 1;

        color =  whatColor(af,threshold);

        dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y-h, w/2, h);
        x +=  w+padding/2;

        avrg /= avrgCount;
        avrgAf /= avrgCount;

        color =  whatColor(avrgAf,threshold);

        var x1 = x0-barWidth/2;
        var x2 = x-w/2-1;
        var y1 = y-avrg;

        dc.setColor(bg,  Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(x1, y1-1, x2, y1-1);

        dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x1, y1-1, x2, y1-1);


        af = avrgAf.format("%.1f");
        var afSize = dc.getTextDimensions(af, BWFace.smallDigitsFont);
        var afW = afSize[0]+9;
        var afH = afSize[1]+5;
        var x3 = x1+4;
        var y3 = y1-afH/2-afTextY;

        if ( y3<(y-height-afTextY)){
            y3 = y-height-afTextY;
        }

        dc.setPenWidth(3);
        dc.setColor(bg,  Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(x3, y3, afW, afH);

        dc.setPenWidth(1);
        dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(x3+1, y3+1, afW-2, afH-2);

        dc.setColor(fg,  Gfx.COLOR_TRANSPARENT);
        dc.drawText(x3+afTextX+afW/2, y3+afTextY, BWFace.smallDigitsFont, af, Gfx.TEXT_JUSTIFY_CENTER);

    }

    function whatColor(af,threshold){
        if (af<1){
            return BWFace.getColor("SurplusColor");
        }
        else {
             return af<=threshold ? BWFace.getColor("ActivityColor") : BWFace.getColor("DeficitColor");
        }
    }
}
