using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class BWFaceRoundApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
    	if( Toybox.WatchUi.WatchFace has :onPartialUpdate ) {
	    	mainView = new BWFaceHRView();
        	return [ mainView, new BWFaceHRDelegate() ];
    	}
    	else {
        	mainView = new BWFaceHRView();
        	return [ mainView ];
        }
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
    	mainView.handlSettingUpdate();
        Ui.requestUpdate();
    }

    var mainView;
}