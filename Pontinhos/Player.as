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
		public function Player(playerColor:Boolean) 
		{
			this.playerColor = playerColor;
			clickedDots = new Array();
		}
		
		/* Abstract function here */
		public function init(dots:Array){} 
		public function canMove(){}
		
		public function move_(dot:Dot)
		{
			clickedDots.push(dot);
			if(clickedDots.length == 2)
				dispatchEvent(new Event(Constants.CONNECT_DOTS_EVENT));
		}
		public function getClickedDots():Array
		{
			/* It returns 2 dots only if refreshDots() was not called */
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
