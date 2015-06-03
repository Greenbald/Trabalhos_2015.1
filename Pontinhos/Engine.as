package  
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.desktop.NativeApplication;
	import Constants;
	import DotBoard;
	import ScreenController;
	public class Engine extends MovieClip
	{
		private var dotBoard:DotBoard;
		public var menu:MenuScreen;
		private var screenController:ScreenController;
		public function Engine() 
		{
			screenStack = new Array();
			setupConstants();
			screenController = new ScreenController(menu);
			screenController.setupMenu();
			screenController.addEventListener(Constants.CHANGE_SCREEN_EVENT, changeScreen);
		}
		public function changeScreen(e:Event)
		{
			var string:String = trim(e.target.text);
			/* Player 1 is always true */
			var color:Boolean = Math.random() > Math.random() ? true : false;
			var screen = screenController.getActualScreen();
			addChild(screen);
			/*removeChild(getActualScreen(screenStack));
			screenStack.push(screenController.getScreen(string, color));
			screenStack.addEventListener(Constants.GO_BACK_EVENT, removeActualScreen);
			screenStack.addEventListener(Constants.GO_BACK_MENU_EVENT, goBackMenu);
			addChild(getActualScreen(screenStack));*/
		}
		function trim(s:String):String
		{
		  return s.replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
		}
		public function setupConstants()
		{
			Constants.NUMBER_OF_DOTS = 8;
			Constants.SCREEN_HEIGHT = stage.stageHeight;
			Constants.SCREEN_WIDTH = stage.stageWidth;
			Constants.DOT_SIZE = (new DotAsset()).width;
			Constants.DOT_MAX_NEIGHBOURS = 4;
		}
		public function removeActualScreen(e:Event)
		{
			removeChild(getActualScreen(screenStack));
			removeActualScreen(screenStack);
			addChild(getActualScreen(screenStack));
		}
		public function goBackMenu(e:Event)
		{
			removeChild(getActualScreen(screenStack));
			removeAllScreensButMenu(screenStack);
			addChild(getActualScreen(screenStack));
		}
	}
}
