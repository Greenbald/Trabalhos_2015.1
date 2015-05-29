package  
{	
	import flash.events.*;
	import Dot;
	import Constants;
	
	public class Player extends EventDispatcher
	{
		protected var playerColor:Boolean;
		protected var clickedDots:Array;
		protected var adversary:Player;
		protected var scorePane;
		protected var points; /* Make this with the score pane */
		public function Player(playerColor:Boolean) 
		{
			this.playerColor = playerColor;
			clickedDots = new Array();
		}
		public function move_(dot:Dot)
		{
			clickedDots.push(dot);
			if(clickedDots.length == 2)
				dispatchEvent(new Event(Constants.CONNECT_DOTS_EVENT));
		}
		public function getClickedDots():Array
		{
			return this.clickedDots;
		}
		public function refreshDots()
		{
			this.clickedDots = new Array();
		}
		
		public function getColor():Boolean
		{
			return this.playerColor;
		}
		
		public function addAdversary(adversary:Player)
		{
			this.adversary = adversary;
		}
		public function getAdversary():Player
		{
			return this.adversary;
		}
	}
}
