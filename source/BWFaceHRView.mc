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
        var clockFont = Ui.loadResource(Rez.Fonts.ClockFont);
        var titlefont = Ui.loadResource(Rez.Fonts.TitleFont);
        var smallTitleFont = Ui.loadResource(Rez.Fonts.SmallTitleFont);

        var color = BWFace.getColor("HoursColor");
        setForView("HourLabel0",times[0],color, clockFont);
        setForView("HourLabel1",times[1],color, clockFont);
        setForView("H12Label",  times[3],color, titlefont);

        color = BWFace.getColor("TimeColonColor");
        setForView("ColumnLabel",times[2],color, clockFont);

        color = BWFace.getColor("MinutesColor");
        setForView("MinutesLabel0",times[4],color, clockFont);
        setForView("MinutesLabel1",times[5],color, clockFont);

        color = BWFace.getColor("ForegroundColor");
        setForView("DateHintLabel","05:40 20:40",color, smallTitleFont);
        setForView("DateLabel",calendar(),color, titlefont);

        //
        // Configurable fields
        //

//		var leftID  = BWFace.getProperty("ActivityLeftField", BW_HeartRate);
//		var midID   = BWFace.getProperty("ActivityMidField",  BW_Steps);
//		var rightID = BWFace.getProperty("ActivityRightField",BW_Calories);

//        var field = new BWFaceValue();
//
//        var values = field.value(leftID);
//        //setForView("Active0",     values[0], color, titlefont);
//        //setForView("Active00",    values[1], color, smallTitleFont);
//        //setForView("Active0Title",values[2], color, smallTitleFont);
//
//        values = field.value(midID);
//        setForView("Active1",     values[0], color, titlefont);
//        setForView("Active10",    values[1], color, smallTitleFont);
//        setForView("Active1Title",values[2], color, smallTitleFont);
//
//        values = field.value(rightID);
//        setForView("Active2",     values[0], color, titlefont);
//        setForView("Active20",    values[1], color, smallTitleFont);
//        setForView("Active2Title",values[2], color, smallTitleFont);

		setForView("BmrLabel", BWFace.bmrDiff().abs().format("%.0f"), color, Ui.loadResource(Rez.Fonts.TitleFont));

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
