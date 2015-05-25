package  
{	
	import flash.display.*;
	import flash.events.*;
	import Constants;
	import Engine;
	import Constants;
	public class DotBoard extends MovieClip
	{
		private var dots:Array;
		private var scorePane:ScorePane;
		private var player1:Player;
		private var player2:Player;
		private var clicks:int;
		private var clickedDots:Array;
		
		public function DotBoard(player1:Player , player2:Player) 
		{
			this.player1 = player1;
			this.player2 = player2;
			clickedDots = new Array();
			clicks = 0;
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
					dots[i][j] = new Dot(i,j, new DotAsset());
					dots[i][j].x = j*space + space;
					dots[i][j].y = i*space + space + menu;
					dots[i][j].addEventListener(MouseEvent.MOUSE_DOWN, onClickDot);
					dots[i][j].addChildren();
					addChild(dots[i][j]);
					/* REMEMBER TO RELEASE ALL EVENTS */
				}
			}
		}
		public function onClickDot(e:Event)
		{
			clicks++;
			clickedDots.push(e.currentTarget);
			if(clicks == 2)
			{
				clicks = 0;
				if(verifyAdjacency(clickedDots[0], clickedDots[1]))
					drawLine(clickedDots);
				clickedDots = new Array();
			}
		}
		public function verifyAdjacency(dot1:Dot, dot2:Dot)
		{
			if(dot1.i - 1 == dot2.i && dot1.j == dot2.j)
				return true;
			else if(dot1.i == dot2.i && dot1.j + 1 == dot2.j)
				return true;
			else if(dot1.i + 1 == dot2.i && dot1.j == dot2.j)
				return true;
			else if(dot1.i == dot2.i && dot1.j - 1 == dot2.j)
				return true;
			return false;
		}
		public function drawLine(dots:Array)
		{
			var haste:Haste = new Haste();
			if(dots[0].i == dots[1].i)
			{
				haste.x = dots[0].x < dots[1].x ? dots[0].x : dots[1].x;
				haste.x += Constants.DOT_SIZE + 3;
				haste.y = dots[0].y;
			}
			else
			{
				var aux:int;
				aux = haste.width;
				haste.width = haste.height;
				haste.height = aux;
				haste.x = dots[0].x;
				haste.y = dots[0].y < dots[1].y ? dots[0].y : dots[1].y;
				haste.y += Constants.DOT_SIZE + 3;
			}
			addChild(haste);
		}
	}
}
