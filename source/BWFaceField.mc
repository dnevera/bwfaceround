using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Time.Gregorian as Calendar;

class ActiveField extends Ui.Drawable {

    var locX;
    var locY;
    var fid;
    var justification;
    var titlePadding;

    function initialize(params, _fid){
        var dictionary = {
            :identifier => _fid
        };
        Drawable.initialize(dictionary);
        locX = params.get(:x);
        locY = params.get(:y);
        justification = params.get(:justification);
        titlePadding = params.get(:titlePadding);
        fid = params.get(:fid);
    }

    (:typecheck(false))
    function draw(dc){

        var field  = new BWFaceValue();
        var values = field.value(BWFace.getProperty(fid, BW_HeartRate));

        var size = dc.getTextDimensions(values[0], BWFace.titleFont);
        var fractSize = dc.getTextDimensions(values[1], BWFace.smallDigitsFont);
        var titleSize = dc.getTextDimensions(values[2], BWFace.smallTitleFont);

        var y  = locY+titleSize[1]+titlePadding;
        var x  = locX;
        var fx = locX;
        var fy = y+size[1]/2-fractSize[1]/2;
        if (justification == Gfx.TEXT_JUSTIFY_LEFT) {
            fx = x + size[0];
        }
        else if (justification == Gfx.TEXT_JUSTIFY_RIGHT) {
            x -= fractSize[0];
        }
        else {
            x -= (fractSize[0]+size[0])/2 - size[0]/2;
            fx = x + fractSize[0]/2+size[0]/2+1;
        }

        dc.setColor(BWFace.getColor("ForegroundColor"),  Gfx.COLOR_TRANSPARENT);
        dc.drawText(x,     y, BWFace.titleFont, values[0], justification);

        if (values[1].length()>0){
            dc.drawText(fx,  fy, BWFace.smallDigitsFont, values[1], justification);
        }

        dc.drawText(locX,  locY, BWFace.smallTitleFont, values[2], justification);
    }

}

class ActiveLeft extends ActiveField {
    function initialize(params) {
        ActiveField.initialize(params,"ActiveLeft");
    }
}

class ActiveMid extends ActiveField {
    function initialize(params) {
        ActiveField.initialize(params,"ActiveMid");
    }
}

class ActiveRight extends ActiveField {
    function initialize(params) {
        ActiveField.initialize(params,"ActiveRight");
    }
}