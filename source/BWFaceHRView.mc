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

        var color = BWFace.getProperty("HoursColor", 0xFFA500);
        setForView("HourLabel0",times[0],color, clockFont);
        setForView("HourLabel1",times[1],color, clockFont);
        setForView("H12Label",  times[3],color, titlefont);

        color = BWFace.getProperty("TimeColonColor", 0xE0E0E0);
        setForView("ColumnLabel",times[2],color, clockFont);

        color = BWFace.getProperty("MinutesColor", 0x32CD32);
        setForView("MinutesLabel0",times[4],color, clockFont);
        setForView("MinutesLabel1",times[5],color, clockFont);

        color = BWFace.getProperty("ForegroundColor", 0x32CD32);
        setForView("DateHintLabel","05:40 20:40",color, smallTitleFont);
        //setForView("WeekOfYearLabel","50",color, titlefont);
        setForView("DateLabel",calendar(),color, titlefont);

        setForView("Active0","1",color, titlefont);
        setForView("Active00","28",color, smallTitleFont);
        setForView("Active0Title","BPM",color, smallTitleFont);

        setForView("Active1","2",color, titlefont);
        setForView("Active10","00",color, smallTitleFont);
        setForView("Active1Title","STEPS",color, smallTitleFont);

        setForView("Active2", "2",color, titlefont);
        setForView("Active20","400",color, smallTitleFont);
        setForView("Active2Title","KCAL",color, smallTitleFont);

        setForView("BmrLabel","3400",color, titlefont);

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
            //var font = Ui.loadResource(Rez.Fonts.TitleFont);
            view.setFont(font);
        }
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}

}
