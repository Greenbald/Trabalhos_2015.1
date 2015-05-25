package  
{	
	import flash.display.*;
	import flash.events.*;
	import Constants;
	import Engine;
	public class DotBoard extends MovieClip
	{
		private var dots:Array;
		private var scorePane:ScorePane;
		public function DotBoard(player1:Player , player2:Player) 
		{
			setupScorePane();
			setupDots();
		}
		private function setupScorePane()
		{
			scorePane = new ScorePane();
			scorePane.player1.text = "00";
			scorePane.player2.text = "00";
			addChild(scorePane);
		}
		private function setupDots()
		{
			dots = new Array(Constants.NUMBER_OF_DOTS);
			var min = Constants.SCREEN_WIDTH > Constants.SCREEN_HEIGHT ? Constants.SCREEN_WIDTH : Constants.SCREEN_HEIGHT;
			var space:int = (min - Constants.NUMBER_OF_DOTS*Constants.DOT_SIZE)/ (Constants.NUMBER_OF_DOTS + 2);
			var menu:int = 120;
			for(var i:int = 0; i < Constants.NUMBER_OF_DOTS; i++)
			{
				dots[i] = new Array(Constants.NUMBER_OF_DOTS);
				for(var j:int = 0; j < Constants.NUMBER_OF_DOTS; j++)
				{
					/* Dot is an object from dots.fla's library. */
					dots[i][j] = new Dot(); 
					dots[i][j].x = j*space + space;
					dots[i][j].y = i*space + space + menu;
					dots[i][j].addEventListener(MouseEvent.MOUSE_DOWN, onClickDot)
					addChild(dots[i][j]);
				}
			}
		}
		public function onClickDot(e:Event)
		{
			trace(e.target.x);
			trace(e.target.y);
		}
	}
}
