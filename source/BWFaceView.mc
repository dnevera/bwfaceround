using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;

class BWFaceHRView extends Ui.WatchFace {

    var field  = new BWFaceValue();

    var isSeccondShown;
    var bg;
    var fg;

    function initialize() {
        WatchFace.initialize();
    }

    var secondsBounds;
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        handlSettingUpdate();
        secondsBounds = dc.getTextDimensions("99", BWFace.titleFont);
    }

    function onShow() {}

    function handlSettingUpdate(){
        isSeccondShown =  BWFace.isSecondsShown();
        bg = BWFace.getColor("BackgroundColor");
        fg = BWFace.getColor("ForegroundColor");
        secondsView = View.findDrawableById("SecondsLabel");
    }

    function onPartialUpdate(dc) {
        secondsUpdate(dc, true);
	}

    var secondsView = null;

    (:typecheck(false))
    function secondsUpdate(dc, clipping){

        if (!isSeccondShown) {return;}

        var x = secondsView.locX;
        var y = secondsView.locY;

		if (clipping){
            dc.setClip(x, y, secondsBounds[0], secondsBounds[1]);
            dc.setColor(bg,  bg);
            dc.clear();
        }

        var seconds = Sys.getClockTime().sec;
        seconds = seconds == null ? "--" : seconds.format("%02.0f");

        dc.setColor(fg, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x,  y, BWFace.titleFont, seconds, Gfx.TEXT_JUSTIFY_LEFT);
    }


    (:typecheck(false))
    function onUpdate(dc) {

        if(isSeccondShown) {dc.clearClip();}

        var hoursColor   = BWFace.getColor("HoursColor");
        var minutesColor = BWFace.getColor("MinutesColor");
        var colonColor   = BWFace.getColor("TimeColonColor");

        var times = BWTime.current();

        setForView("HourLabel0", times[0], hoursColor, BWFace.clockFont);
        setForView("HourLabel1", times[1], hoursColor, BWFace.clockFont);

        setForView("ColonLabel", times[2], colonColor, BWFace.clockFont);
        setForView("H12Label0",   times[3], hoursColor, BWFace.titleFont);
        setForView("H12Label1",   times[4], hoursColor, BWFace.titleFont);

        setForView("MinutesLabel0", times[5], minutesColor, BWFace.smallClockFont);
        setForView("MinutesLabel1", times[6], minutesColor, BWFace.smallClockFont);

        var values = field.value(BW_SunriseSunset);
        setForView("SSLabel",  values[0]+values[1]+values[2], fg, BWFace.smallDigitsFont);

        values = field.value(BWFace.getProperty("HintField", BW_ActivityFactor));

        var txt   = values[0]+values[1];
        var dt    = calendar();
        var title = values[2];

        var hintLabel = setForView("HintLabel", txt, fg, BWFace.titleFont);
        var dateLabel = setForView("DateLabel", dt, fg, BWFace.titleFont);
        var hintTitle = setForView("HintLabelTitle", null, fg, BWFace.smallTitleFont);

        var dtSize = dc.getTextDimensions(dt, BWFace.titleFont);
        var size   = dc.getTextDimensions(txt, BWFace.titleFont);
        var tsize  = dc.getTextDimensions(title, BWFace.smallTitleFont);

        if ((hintLabel.locX+size[0]+tsize[0])<(dateLabel.locX-dtSize[0])){
            hintTitle.locX = hintLabel.locX + size[0];
            hintTitle.setText(title);
        }
        else {
            hintTitle.setText("");
        }

        View.onUpdate(dc);

        secondsUpdate(dc, false);
    }

    function calendar(){
        var months = Ui.loadResource(Rez.Strings.Months);
        var weekDays = Ui.loadResource(Rez.Strings.WeekDays);

        var today = BWTime.today();
    	var weekDay = 4*(today.day_of_week-1);
        var month = 5*(today.month-1);

        month   = months.substring(month,month+5);
        var s = month.find(" ");
        if (s != null){
            month = month.substring(0,s);
        }

        weekDay = weekDays.substring(weekDay,weekDay+4);
        s = weekDay.find(" ");
        if (s != null){
            weekDay = weekDay.substring(0,s);
        }

    	return Lang.format("$1$ $2$ $3$",[weekDay, today.day,month]).toUpper();
    }

    function setForView(id,text,color,font){
        var view = View.findDrawableById(id) as Ui.Text;

        if (font !=null) { view.setFont(font);   }
        if (color!=null) { view.setColor(color); }
        if (text !=null) { view.setText(text);   }

        return view;
    }

    function onExitSleep() {
        BWFace.powerBudgetExceeded   = false;
        if(!BWFace.partialUpdatesAllowed) {Ui.requestUpdate();}
    }

    function onEnterSleep() {
    	if(!BWFace.partialUpdatesAllowed) {Ui.requestUpdate();}
    }

    function onHide() {}
}

// https://forums.garmin.com/forum/developers/connect-iq/1229818-watch-face-onpartialupdate-does-not-work-on-all-devices-which-support-this-function
// with onPartialUpdate, the println()'s are useful for debugging.
// If you exceed the budget, you can see by how much, etc.  The do1hz is used in onUpdate()
// and is key.
class BWFaceHRDelegate extends Ui.WatchFaceDelegate
{

	function initialize() {
		WatchFaceDelegate.initialize();
	}

    function onPowerBudgetExceeded(powerInfo) {
        BWFace.powerBudgetExceeded=true;
        Sys.println( "Average execution time: " + powerInfo.executionTimeAverage );
        Sys.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
    }
}
