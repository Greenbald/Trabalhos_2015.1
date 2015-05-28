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
		private var color:Boolean;
		private var clicks:int;
		private var clickedDots:Array;
		private var geometric:Array;
		private var bButton:BackButton;
		
		public function DotBoard(player1:Player , player2:Player) 
		{
			this.player1 = player1;
			this.player2 = player2;
			clickedDots = new Array();
			clicks = 0;
			setupScorePane();
			setupDots();
			setupBackButton();
			color = true;
			geometric = new Array();
			geometric.push(bButton, scorePane);
		}
		private function setupScorePane()
		{
			scorePane = new ScorePane();
			scorePane.player1.text = "0";
			scorePane.player2.text = "0";
			addChild(scorePane);
		}
		private function setupDots()
		{
			dots = new Array(Constants.NUMBER_OF_DOTS);
			var min = Constants.SCREEN_WIDTH > Constants.SCREEN_HEIGHT ? Constants.SCREEN_WIDTH : Constants.SCREEN_HEIGHT;
			var space:int = (min - Constants.NUMBER_OF_DOTS*Constants.DOT_SIZE)/ (Constants.NUMBER_OF_DOTS + 2);
			Constants.DOT_DISTANCE = space;
			var menu:int = 120;
			for(var i:int = 0; i < Constants.NUMBER_OF_DOTS; i++)
			{
				dots[i] = new Array(Constants.NUMBER_OF_DOTS);
				for(var j:int = 0; j < Constants.NUMBER_OF_DOTS; j++)
				{
					/* Dot is an object from dots.fla's library. */
					dots[i][j] = new Dot(i,j, new DotAsset(), -1);
					dots[i][j].x = j*space + space;
					dots[i][j].y = i*space + space + menu;
					dots[i][j].addEventListener(MouseEvent.MOUSE_DOWN, onClickDot);
					dots[i][j].addChildren();
					addChild(dots[i][j]);
					/* REMEMBER TO RELEASE ALL EVENTS */
				}
			}
		}
		private function setupBackButton()
		{
			bButton = new BackButton();
			bButton.addEventListener(MouseEvent.MOUSE_DOWN, goBackToMenu);
			bButton.x = Constants.SCREEN_WIDTH/2 -  bButton.width/2;
			bButton.y = 580;
			addChild(bButton);
		}
		public function onClickDot(e:Event)
		{
			changeDotColor(Dot(e.currentTarget));
			clicks++;
			clickedDots.push(e.currentTarget);
			if(clicks == 2)
			{
				clicks = 0;
				if(verifyAdjacency(clickedDots[0], clickedDots[1]) && !clickedDots[0].isConnectedToB(clickedDots[1]))
				{
					drawLine(clickedDots[0], clickedDots[1], color);
					connect(clickedDots[0], clickedDots[1], color);
					removeListenerIfMaxNeighbours(clickedDots[0], clickedDots[1]);
					if(!drawSquareIfClosed(clickedDots[0], clickedDots[1], color))
						color = !color;
					
					trace("Dot 1 Neighbours : "+clickedDots[0].getNumberOfNeighbours());
					trace("Dot 2 Neighbours : "+clickedDots[1].getNumberOfNeighbours());
				}
				refreshDotColors(clickedDots[0], clickedDots[1]);
				clickedDots = new Array();
			}
		}
		public function changeDotColor(dotNode:Dot)
		{
			dotNode.dot.gotoAndStop(2);
		}
		public function connect(dot1:Dot, dot2:Dot, color:Boolean)
		{
			dot1.addEdge(dot2, color);
			dot2.addEdge(dot1, color);
		}
		public function removeListenerIfMaxNeighbours(dot1:Dot, dot2:Dot)
		{
			if(dot1.getNumberOfNeighbours() == Constants.DOT_MAX_NEIGHBOURS)
				dot1.removeEventListener(MouseEvent.MOUSE_DOWN, onClickDot);
			if(dot2.getNumberOfNeighbours() == Constants.DOT_MAX_NEIGHBOURS)
				dot2.removeEventListener(MouseEvent.MOUSE_DOWN, onClickDot);
		}
		public function drawSquareIfClosed(dot1:Dot, dot2:Dot, color:Boolean):Boolean
		{
			if(dot1.i == dot2.i)
			{
				if(dot1.i != 0 && dot2.i != 0)
				{
					var top1, top2;
					top1 = dot1.isConnectedTo(dot1.i - 1, dot1.j);
					top2 = dot2.isConnectedTo(dot2.i - 1, dot2.j);
					
					if(top1 != null && top2 != null && top1.isConnectedToB(top2))
					{
					   drawSquare(top1.j > top2.j ? top2 : top1, color); 
					   return true;
					}
				}
				if(dot1.i != Constants.NUMBER_OF_DOTS - 1)
				{
					var down1, down2;
					down1 = dot1.isConnectedTo(dot1.i + 1, dot1.j);
					down2 = dot2.isConnectedTo(dot2.i + 1, dot2.j);
					
					if(down1 != null && down2 != null && down1.isConnectedToB(down2))
					{
					   drawSquare(dot1.j > dot2.j ? dot2 : dot1, color); 
					   return true;
					}
				}
			}
			else
			{
				if(dot1.j != 0 && dot2.j != 0)
				{
					var left1, left2;
					left1 = dot1.isConnectedTo(dot1.i, dot1.j - 1);
					left2 = dot2.isConnectedTo(dot2.i, dot2.j - 1);
					
					if(left1 != null && left2 != null && left1.isConnectedToB(left2))
					{
					   drawSquare(left1.i > left2.i ? left2 : left1, color); 
					   return true;
					}
				}
				if(dot1.j != Constants.NUMBER_OF_DOTS - 1)
				{
					var right1, right2;
					right1 = dot1.isConnectedTo(dot1.i, dot1.j + 1);
					right2 = dot2.isConnectedTo(dot2.i, dot2.j + 1);
					
					if(right1 != null && right2 != null && right1.isConnectedToB(right2))
					{
					   drawSquare(dot1.i > dot2.i ? dot2 : dot1, color); 
					   return true;
					}
				}
			}
			return false;
		}
		public function drawSquare(originNode:Dot, color:Boolean)
		{
			var square;
			if(color)
				square = new BlueSquare();
			else
				square = new RedSquare();
			square.x = originNode.x + (Constants.DOT_DISTANCE + Constants.DOT_SIZE)/2 - square.width/2;
			square.y = originNode.y + (Constants.DOT_DISTANCE + Constants.DOT_SIZE)/2 - square.height/2;
			refreshScore(color);
			addChild(square);
			geometric.push(square);
			
		}
		public function refreshScore(color:Boolean)
		{
			if(color)
				scorePane.player1.text = String(parseInt(scorePane.player1.text) + 1);
			else
				scorePane.player2.text = String(parseInt(scorePane.player2.text) + 1);
		}
		public function refreshDotColors(dotNode1:Dot, dotNode2:Dot)
		{
			/* dots array has size equals to 2, selected dots. */
			dotNode1.dot.gotoAndStop(1);
			dotNode2.dot.gotoAndStop(1);
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
		public function drawLine(dot1:Dot, dot2:Dot, color:Boolean)
		{
			/* We suppose a haste with fixed size of 30, for a dot of size 15x15 */
			var haste;
			if(color)
				haste = new BlueHaste();
			else
				haste = new RedHaste();
			var h = (Constants.DOT_DISTANCE + Constants.DOT_SIZE)/2 - (haste.width > haste.height ? haste.width : haste.height)/2
			if(dot1.i == dot2.i)
			{
				haste.x = dot1.x < dot2.x ? dot1.x : dot2.x;
				haste.x += h;
				haste.y = dot1.y;
			}
			else
			{
				haste.rotation += 90;
				haste.x = dot1.x + haste.width;
				haste.y = dot1.y < dot2.y ? dot1.y : dot2.y;
				haste.y += h;
			}
			addChild(haste);
			geometric.push(haste);
		}
		public function goBackToMenu(e:Event)
		{
			for(var i:int = 0; i < geometric.length; i++)
				removeChild(geometric[i]);
			for(var k:int = 0; k < dots.length; k++)
			{
				for(var j:int = 0; j < dots[k].length; j++)
				{
					dots[k][j].removeChildrens();
					dots[k][j].removeEventListener(MouseEvent.MOUSE_DOWN, onClickDot);
				}
			}
			bButton.removeEventListener(MouseEvent.MOUSE_DOWN, goBackToMenu);
			dispatchEvent(new Event(Constants.GO_BACK_MENU_EVENT));
		}
	}
}
