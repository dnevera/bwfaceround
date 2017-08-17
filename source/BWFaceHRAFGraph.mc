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
    //var font;

    function initialize(params) {
        var dictionary = {
            :identifier => "AFGraph"
        };

        Drawable.initialize(dictionary);
        locX = params.get(:x);
        locY = params.get(:y);
        height = params.get(:height);
        //font = params.get(:font);
    }

    function draw(dc) {
        graphsField(dc,locX,locY, height);
    }

     function graphsField(dc,locX,locY, height) {

        var padding = 2;
        var hist = ActivityMonitor.getHistory();
        var calories = ActivityMonitor.getInfo().calories;

        //var font = Gfx.FONT_XTINY; //properties.fonts.infoTitleFontTiny;
        var font = Ui.loadResource(Rez.Fonts.TitleFont);
        var colSize = dc.getTextDimensions("W", font);
        var w      = (colSize[0]+padding/2) * 2;
        var offset = w/2+padding/2;

        var count;
        var start;
        var start0 = 8;
        var shift;

//        if (
//        properties.metricField == BW_HeartRate ||
//        properties.metricField == BW_Temperature ||
//        properties.metricField == BW_Pressure
//        ) {
            count = 8;
            start = hist.size()-1;
            shift = colSize[0]/2;
//        }
//        else {
//            count = 7;
//            start = hist.size()-2;
//            shift = colSize[0]/2;
//            start0 -= 1;
//        }

        var x0 = locX - (offset)*count/2 + shift;
        var y = locY+colSize[1]+padding;
        var x = x0;

        dc.setColor(BWFace.getProperty("ForegroundColor",0xFFFFFF),  Gfx.COLOR_TRANSPARENT);
        if (hist.size()==0){

            x +=  offset;
            for (var i = start0-1; i>=2; i--){
                var m = new Time.Moment(Time.today().value()-3600*24*i);
                var t = Calendar.info(m, Time.FORMAT_MEDIUM);
                dc.drawText(x, y, font, t.day_of_week.toString().substring(0, 1), Gfx.TEXT_JUSTIFY_CENTER);
                dc.fillRectangle(x-colSize[0]/2, y-1, w/2, 1);
                x +=  offset;
            }
            return;
        }

        x = x0+padding/2;
        var min0 = 100000;
        var max0 = 0.1;
        //x +=  offset+1;
        for (var i = start; i>=0; i--){
            var t = Calendar.info(hist[i].startOfDay, Time.FORMAT_MEDIUM);

            if (hist[i].calories<min0) { min0 = hist[i].calories; }
            if (hist[i].calories>max0) { max0 = hist[i].calories; }
            var vd =  t.day_of_week.toString().substring(0, 1);
            if (i <= start-1 && i>=0){
                dc.drawText(x, y, font, vd, Gfx.TEXT_JUSTIFY_CENTER);
            }
            x +=  offset;
        }

        //var m = new Time.Moment(Time.today().value());
        //var t = Calendar.info(m, Time.FORMAT_MEDIUM);
        //dc.drawText(x, y, font, t.day_of_week.toString().substring(0, 1), Gfx.TEXT_JUSTIFY_CENTER);

        if (calories<min0) { min0 = calories; }
        if (calories>max0) { max0 = calories; }

        var threshold = BWFace.getProperty("ActivityFactorThreshold", 1.5);

        var bmr = BWFace.bmr();

        x = x0-colSize[0]/2;
        var avrg = 0;
        var avrgAf = 0;
        var avrgCount = 0;
        var color;
        for (var i = start; i>=0; i--){
            var af = hist[i].calories/bmr;
            avrgAf += af;
            var h = height * hist[i].calories/max0;
            if (af<1){
                color = BWFace.getProperty("SurplusColor",0x555555);
            }
            else if (af>=threshold) {
                color = BWFace.getProperty("DeficitColor",0xFFFFFF);
            }
            else {
                color = BWFace.getProperty("ActivityColor",0xAAAAAA);
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

        var x1 = x0-colSize[0]/2;
        var x2 = x-w/2-1;
        var y1 = y-avrg;

        dc.setColor(BWFace.getProperty("BackgroundColor",0x000000),  Gfx.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1+2, x2, y1+2);
        dc.drawLine(x1, y1-1, x2, y1-1);

        dc.setColor(color,  Gfx.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1, x2, y1);
        dc.drawLine(x1, y1+1, x2, y1+1);
    }

    function whatColor(af,threshold){
        if (af<1){
            return BWFace.getProperty("SurplusColor",0x555555);
        }
        else {
             return af<=threshold ? BWFace.getProperty("ActivityColor",0xAAAAAA) : BWFace.getProperty("DeficitColor",0xFFFFFF);
        }
    }
}
