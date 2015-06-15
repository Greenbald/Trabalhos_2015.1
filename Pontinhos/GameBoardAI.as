package  
{
	import Edge;
	import Constants;
	public class GameBoardAI 
	{
		private board:Array;
		private bestScore:int;
		private scoreBoard:Object;
		public function GameBoardAI(board:Array) 
		{
			this.board = board;
			scoreBoard[true] = 0;
			scoreBoard[false] = 0;
		}
		public function executeMove(e:Edge, turn:Boolean):Boolean
		{
			e.setVisited(true);
			var closedSquares = numberOfSquares(e);
			board[e.getDot().i][e.getDot().j].addEdge(e.getDot(), e.getConnectedDot());
			board[e.getConnectedDot().i][e.getConnectedDot().j].addEdge(e.getConnectedDot(), e.getDot());
			if(closedSquares > 0)
				scoreBoard[turn] += closedSquares;
			else
				return !turn;
			return turn;
			
		}
		public function unexecuteMove(e:Edge, turn:Boolean):Boolean
		{
			e.setVisited(false);
			board[e.getDot().i][e.getDot().j].removeEdge(e.getDot(), e.getConnectedDot());
			board[e.getConnectedDot().i][e.getConnectedDot().j].removeEdge(e.getConnectedDot(), e.getDot());
			var openSquares = numberOfSquares(e);
			if(openSquares > 0)
				scoreBoard[turn] -= openSquares;
			else
				return !turn;
			return turn;
		}

		/* 0 <= RETURN VALUE <= 2*/
		private function numberOfSquares(edge:Edge):int
		{
			var node1:Dot, node2:Dot;
			node1 = edge.getDot();
			node2 = edge.getConnectedDot();
			var nSquares:int = 0;
			
			if(node1.i == node2.i) /* Horizontal haste */
			{
				var min = node1.j < node2.j ? node1 : node2;
				node2 = node1.j > node2.j ? node1 : node2;
				node1 = min;
				
				/* Check for a square above the haste */ 
				if(node1.i > 0  && 
				   node1.isConnectedToB(dots[node1.i-1][node1.j]) &&
				   node2.isConnectedToB(dots[node2.i-1][node2.j]) &&
				   dots[node1.i-1][node1.j].isConnectedToB(dots[node2.i-1][node2.j]))
				   nSquares += 1;
				/* Check for a square below the haste */ 
				if(node1.i < Constants.NUMBER_OF_DOTS - 1 &&
				   node1.isConnectedToB(dots[node1.i+1][node1.j]) &&
				   node2.isConnectedToB(dots[node2.i+1][node2.j]) &&
				   dots[node1.i+1][node1.j].isConnectedToB(dots[node2.i+1][node2.j]))
				   nSquares += 1;
			}
			else /* Vertical haste */
			{
				
				var min2 = node1.i < node2.i ? node1 : node2;
				node2 = node1.i > node2.i ? node1 : node2;
				node1 = min2;
				
				/* Check for a square left the haste */
				if(node1.j > 0 &&
				   node1.isConnectedToB(dots[node1.i][node1.j-1]) &&
				   node2.isConnectedToB(dots[node2.i][node2.j-1]) &&
				   dots[node1.i][node1.j-1].isConnectedToB(dots[node2.i][node2.j-1]))
				   nSquares += 1;
				/* Check for a square right the haste */
				if(node1.j < Constants.NUMBER_OF_DOTS - 1 &&
				   node1.isConnectedToB(dots[node1.i][node1.j+1]) && 
				   node2.isConnectedToB(dots[node2.i][node2.j+1]) &&
				   dots[node1.i][node1.j+1].isConnectedToB(dots[node2.i][node2.j+1]))
				   nSquares += 1;
				  
			}
			return nSquares;
		}
	}
	
}
