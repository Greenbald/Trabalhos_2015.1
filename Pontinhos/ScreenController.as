package  
{
	import flash.display.*;
	import flash.events.*;
	import Engine;
	public class ScreenController 
	{
		private var menu:MenuScreen;
		private var screenStack:Array;
		public function ScreenController(menu:MenuScreen) 
		{
			this.menu = menu;
		}
		public function setupMenu()
		{
			menu = new MenuScreen();
			addMenuEventListeners();
			screenStack.push(menu);
		}
		public function eventHandler(type:String, color:Boolean = null):MovieClip
		{
			switch(string)
			{
				case "One Player":
					difficultyScreen = new DifficultyScreen();
					difficultyScreen.medium.addEventListener(MouseEvent.MOUSE_DOWN, difficultyEventHandler);
					difficultyScreen.expert.addEventListener(MouseEvent.MOUSE_DOWN, difficultyEventHandler);
					screenStack.push(difficultyScreen);
					dispatchEvent(new Event(Constants.CHANGE_SCREEN_EVENT));
					return 
					//return new DotBoard(new Player(color), new AI(!color));
					break;
				case "Two Players":
					return new DotBoard(new Player(color), new Player(!color));
					break;
				case "AI Game":
					//return new DotBoard(new AI(color), new AI(!color));
					break;
				case "Exit":
					NativeApplication.nativeApplication.exit(); 
					break;
			}
		}
		
		public function getActualScreen():MovieClip
		{
			return screenStack[screenStack.length-1];
		}
		public function removeActualScreen()
		{
			if( screenStack.length > 0 )
				screenStack.pop()
		}
		/*public function removeAllScreensButMenu(arr:Array)
		{
			screenStack = new Array();
			screenStack.push(menu);
		}*/
		private function addMenuEventListeners()
		{
			menu.exitGame.addEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			menu.twoPlayerGame.addEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			menu.onePlayerGame.addEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			menu.AIGame.addEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
		}
		private function removeMenuEventListeners()
		{
			menu.exitGame.removeEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			menu.twoPlayerGame.removeEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			menu.onePlayerGame.removeEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
			menu.AIGame.removeEventListener(MouseEvent.MOUSE_DOWN, eventHandler);
		}
	}
}
