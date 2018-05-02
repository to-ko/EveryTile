using Toybox.Application as App;
class EveryTileApp extends App.AppBase {
    function initialize() {
       AppBase.initialize();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [new EveryTileView()];
    }
}