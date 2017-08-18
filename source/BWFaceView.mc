using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Calendar;

class BWFaceHRView extends Ui.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {}

    function onUpdate(dc) {

        var times = BWTime.current();

        var color = BWFace.getColor("HoursColor");
        setForView("HourLabel0",times[0],color, BWFace.clockFont);
        setForView("HourLabel1",times[1],color, BWFace.clockFont);
        setForView("H12Label",  times[3],color, BWFace.titleFont);

        color = BWFace.getColor("TimeColonColor");
        setForView("ColumnLabel",times[2],color, BWFace.clockFont);

        color = BWFace.getColor("MinutesColor");
        setForView("MinutesLabel0",times[4],color, BWFace.smallClockFont);
        setForView("MinutesLabel1",times[5],color, BWFace.smallClockFont);

        color = BWFace.getColor("ForegroundColor");
        var field  = new BWFaceValue();
        var values = field.value(BWFace.getProperty("HintField", BW_SunriseSunset));

        setForView("HintLabel",values[0]+values[1]+" "+values[2],color, BWFace.smallTitleFont);

        values = field.value(BW_SunriseSunset);
        setForView("SSLabel",values[0]+values[1]+" "+values[2],color, BWFace.smallTitleFont);

        setForView("DateLabel",calendar(),color, BWFace.titleFont);

		setForView("BmrLabel", BWFace.bmrDiff().abs().format("%.0f"), color, BWFace.titleFont);

        View.onUpdate(dc);
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
        view.setColor(color);
        view.setText(text);
        if (font!=null){
            view.setFont(font);
        }
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}

}
