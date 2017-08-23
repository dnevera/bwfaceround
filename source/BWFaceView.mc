using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;

class BWFaceHRView extends Ui.WatchFace {

    var field  = new BWFaceValue();

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {}

    var isSeccondShown =  BWFace.isSecondsShown();
    function handlSettingUpdate(){
       isSeccondShown =  BWFace.isSecondsShown();
    }

    function onPartialUpdate(dc) {
        secondsUpdate(dc, true);
	}

	var seconds = null;
    var secondsView = null;

    function secondsUpdate(dc, clipping){

        if (!isSeccondShown) {
            return;
        }

        if (secondsView == null) {
            secondsView = View.findDrawableById("SecondsLabel");
        }

		if (clipping){
            dc.setClip(secondsView.locX-20, secondsView.locY, 50, 30);
        }

        if (seconds != null ){
            dc.setColor(BWFace.getColor("BackgroundColor"), Gfx.COLOR_TRANSPARENT);
            dc.drawText(secondsView.locX,  secondsView.locY, BWFace.titleFont, seconds, Gfx.TEXT_JUSTIFY_LEFT);
        }
        seconds = field.value(BW_Seconds)[0];
        dc.setColor(BWFace.getColor("ForegroundColor"), Gfx.COLOR_TRANSPARENT);
        dc.drawText(secondsView.locX,  secondsView.locY, BWFace.titleFont, seconds, Gfx.TEXT_JUSTIFY_LEFT);
    }

    function onUpdate(dc) {

        isSeccondShown =  BWFace.isSecondsShown();

        var times = BWTime.current();

        if(isSeccondShown) {dc.clearClip();}

//        if (isSeccondShown){
//            dc.setClip(0, 0, dc.getWidth(), dc.getHeight());
//        }

        var color = BWFace.getColor("HoursColor");
        setForView("HourLabel0", times[0],color, BWFace.clockFont);
        setForView("HourLabel1", times[1],color, BWFace.clockFont);
        setForView("H12Label0",  times[3].substring(0,1), color, BWFace.titleFont);
        setForView("H12Label1",  times[3].substring(1,2), color, BWFace.titleFont);

        color = BWFace.getColor("TimeColonColor");
        setForView("ColumnLabel",times[2],color, BWFace.clockFont);

        color = BWFace.getColor("MinutesColor");
        setForView("MinutesLabel0",times[4],color, BWFace.smallClockFont);
        setForView("MinutesLabel1",times[5],color, BWFace.smallClockFont);

        color = BWFace.getColor("ForegroundColor");
        var values = field.value(BWFace.getProperty("HintField", BW_ActivityFactor));

        var dt = calendar();
        var dtSize = dc.getTextDimensions(dt, BWFace.titleFont);

        var txt = values[0]+values[1];
        var title = values[2];
        var size = dc.getTextDimensions(txt, BWFace.titleFont);
        var tsize = dc.getTextDimensions(title, BWFace.smallTitleFont);

        var hint = setForView("HintLabel", txt, color, BWFace.titleFont);
        var date = setForView("DateLabel", dt, color, BWFace.titleFont);

        if ((hint.locX+size[0]+tsize[0])<(date.locX-dtSize[0])){
            var hintTitle = setForView("HintLabelTitle", title, color, BWFace.smallTitleFont);
            hintTitle.locX = hint.locX + size[0];
        }
        else {
            setForView("HintLabelTitle", "", color, BWFace.smallTitleFont);
        }

        values = field.value(BW_SunriseSunset);
        setForView("SSLabel",values[0]+values[1]+values[2], color, BWFace.smallDigitsFont);

		setForView("BmrLabel", BWFace.bmrDiff().abs().format("%.0f"), color, BWFace.titleFont);

        View.onUpdate(dc);

        secondsUpdate(dc, true);
    }

    function calendar(){
        var months = Ui.loadResource(Rez.Strings.Months);
        var weekDays = Ui.loadResource(Rez.Strings.WeekDays);

        var today = BWTime.today();
        var ss = "";

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
        var view = View.findDrawableById(id);
        if (font!=null){
            view.setFont(font);
        }
        view.setColor(color);
        view.setText(text);
        return view;
    }

    function onExitSleep() {
    	BWFace.partialUpdatesAllowed = Toybox.WatchUi.WatchFace has :onPartialUpdate;
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
        BWFace.partialUpdatesAllowed=false;
    }
}
