package  
{
	import flash.utils.ByteArray; 
	import Constants;
	import Edge;
	import Dot;
	public class GameState 
	{
		private var board:Array;
		private var legalMoves:Array;
		private var bestHaste:Edge
		public function GameState(dots:Array) 
		{
			board = new Array(Constants.NUMBER_OF_DOTS);
			for(var i:int = 0; i < Constants.NUMBER_OF_DOTS; i++)
			{
				board[i] = new Array();
				for(var j:int = 0; j < Constants.NUMBER_OF_DOTS; j++)
				{
					board[i].push(dots[i][j].clone());
				}
			}
			legalMoves = connectEdges(dots);
		}
		public function connectEdges(dots:Array)
		{
			var edges = new Array();
			for(var i:int = 0; i < dots.length; i++)
			{
				for(var j:int = 0; j < dots[i].length; j++)
				{
					if(j < Constants.NUMBER_OF_DOTS - 1)
					{
						if(!dots[i][j].isConnectedTo(i, j+1))
							edges.push(new Edge(this.board[i][j], this.board[i][j+1]));
						else
							addEdge(board[i][j], board[i][j+1]);
							
					}
					if(i < Constants.NUMBER_OF_DOTS - 1)
					{
						if(!dots[i][j].isConnectedTo(i+1, j))
							edges.push(new Edge(this.board[i][j], this.board[i+1][j]));
						else
							addEdge(board[i][j], board[i+1][j]);
					}
				}
			}
			return edges;
		}
		public function addEdge(dot1:Dot, dot2:Dot)
		{
			dot1.addEdge(dot1,dot2, true);
			dot2.addEdge(dot2,dot1, true);
		}
		public function getState():Array
		{
			return this.board;
		}
		
		public function getLegalMoves():Array
		{
			return this.legalMoves;
		}
		public function addHaste(e:Edge)
		{
			bestHaste = e;
			var arr:Array = new Array();
			for(var i:int = 0; i < legalMoves.length; i++)
			{
				if(legalMoves[i] != e)
					arr.push(legalMoves[i]);
			}
			legalMoves = arr;
			board[e.getDot().i][e.getDot().j].addEdge(e.getDot(), e.getConnectedDot(), true);
			board[e.getConnectedDot().i][e.getConnectedDot().j].addEdge(e.getConnectedDot(), e.getDot(), true);
		}
		public function removeHaste(e:Edge)
		{
			legalMoves.push(e);
			board[e.getDot().i][e.getDot().j].removeEdge(e.getDot(), e.getConnectedDot());
			board[e.getConnectedDot().i][e.getConnectedDot().j].removeEdge(e.getConnectedDot(), e.getDot());
		}
		public function cloneGameState()
		{
			return new GameState(this.getState());
		}
		public function getSolution():Edge
		{
			return this.bestHaste;
		}
	}
}
