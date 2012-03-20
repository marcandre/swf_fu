import flash.external.ExternalInterface;
import mx.utils.Delegate;

dynamic class Example extends MovieClip {

	function Example() {
		this.info = createTextField("info", getNextHighestDepth(), 0, 0, Stage.width, Stage.height);
		this.log(_level0.message ? _level0.message : "Hello, world!\n");
		ExternalInterface.addCallback("sendFlash", this, this.receiveFromJS);
	}
	
	function callJS(arg) {
		ExternalInterface.call("receiveFromFlash", arg);
	}

  function receiveFromJS(arg) {
    this.log("Received from JS: "+arg+"\n");
    this.callJS("Thanks for: "+arg);
  }
  
  function log(txt) {
    this.info.text += txt;
  }
  
  private var info: TextField;
}