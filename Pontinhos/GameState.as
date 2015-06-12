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
			board = new Array();
			for(var i:int = 0; i < dots[0].length; i++)
			{
				board.push(dots[i].slice(0));
			}
			legalMoves = initLegalMoves();
		}
		public function getState():Array
		{
			return this.board;
		}
		private function initLegalMoves():Array
		{
			var edges = new Array();
			for(var i:int = 0; i < this.board.length; i++)
			{
				for(var j:int = 0; j < this.board[i].length; j++)
				{
					if(j < Constants.NUMBER_OF_DOTS - 1)
					{
						if(!this.board[i][j].isConnectedTo(i, j+1))
							edges.push(new Edge(this.board[i][j], this.board[i][j+1]));
					}
					if(i < Constants.NUMBER_OF_DOTS - 1)
					{
						if(!this.board[i][j].isConnectedTo(i+1, j))
							edges.push(new Edge(this.board[i][j], this.board[i+1][j]));
					}
				}
			}
			return edges;
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
