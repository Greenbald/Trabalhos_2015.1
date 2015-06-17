package  
{
	import Edge;
	import Constants;
	public class GameBoardAI 
	{
		/* The board itself */
		private var board:Array;
		
		/* The bestScore so far */
		public var bestScore:int;
		
		/* scoreBoard is a map that correlates a player with his score */
		public var scoreBoard:Object;
		public function GameBoardAI(board:Array) 
		{
			/* This class is an abstraction for the board which the AI
			will have until the leaf of alphabeta(when the board is in the game over state).
			When it's in the leaf of alphabeta the scoreBoard represents the total score for each player.*/
			this.board = board;
			scoreBoard = new Object();
			scoreBoard[true] = 0;
			scoreBoard[false] = 0;
		}
		/* 
		This function just insert the edge in the board, and sums the number of squares that is being closed by
		this edge and return the new turn, if closedSquares > 0, it will return the same turn received as parameter,
		otherwise return !turn.
		*/
		public function executeMove(e:Edge, turn:Boolean):Boolean
		{
			e.setVisited(true);
			var closedSquares = numberOfSquares(e);
			board[e.getDot().i][e.getDot().j].addEdge(e.getDot(), e.getConnectedDot(), turn);
			board[e.getConnectedDot().i][e.getConnectedDot().j].addEdge(e.getConnectedDot(), e.getDot(), turn);
			if(closedSquares > 0)
				scoreBoard[turn] += closedSquares;
			else
				return !turn;
			return turn;
			
		}
		/* 
		This functions undo the move and returns the turn that was before, remove any score that was added by a closed
		square.
		*/
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

		/* this function just calculate the number of squares that is closed using the edge PARAMETER */
		/* 0 <= RETURN VALUE <= 2*/
		public function numberOfSquares(edge:Edge):int
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
				   node1.isConnectedToB(board[node1.i-1][node1.j]) &&
				   node2.isConnectedToB(board[node2.i-1][node2.j]) &&
				   board[node1.i-1][node1.j].isConnectedToB(board[node2.i-1][node2.j]))
				   nSquares += 1;
				/* Check for a square below the haste */ 
				if(node1.i < Constants.NUMBER_OF_DOTS - 1 &&
				   node1.isConnectedToB(board[node1.i+1][node1.j]) &&
				   node2.isConnectedToB(board[node2.i+1][node2.j]) &&
				   board[node1.i+1][node1.j].isConnectedToB(board[node2.i+1][node2.j]))
				   nSquares += 1;
			}
			else /* Vertical haste */
			{
				
				var min2 = node1.i < node2.i ? node1 : node2;
				node2 = node1.i > node2.i ? node1 : node2;
				node1 = min2;
				
				/* Check for a square left the haste */
				if(node1.j > 0 &&
				   node1.isConnectedToB(board[node1.i][node1.j-1]) &&
				   node2.isConnectedToB(board[node2.i][node2.j-1]) &&
				   board[node1.i][node1.j-1].isConnectedToB(board[node2.i][node2.j-1]))
				   nSquares += 1;
				/* Check for a square right the haste */
				if(node1.j < Constants.NUMBER_OF_DOTS - 1 &&
				   node1.isConnectedToB(board[node1.i][node1.j+1]) && 
				   node2.isConnectedToB(board[node2.i][node2.j+1]) &&
				   board[node1.i][node1.j+1].isConnectedToB(board[node2.i][node2.j+1]))
				   nSquares += 1;
				  
			}
			return nSquares;
		}
		/* It checks for a square that will be closed in the next turn, based on the move of the actual turn */ 
		public function checkFutureSquare(edge:Edge):int
		{
			var node1 = edge.getDot();
			var node2 = edge.getConnectedDot();
			var futureSquares:int = 0;
			if(node1.j == node2.j)
			{
				var min2 = node1.i < node2.i ? node1 : node2;
				node2 = node1.i > node2.i ? node1 : node2;
				node1 = min2;
				if(node1.j > 0)
				{
					if(node1.isConnectedToB(board[node1.i][node1.j-1]) &&
					   board[node1.i][node1.j-1].isConnectedToB(board[node2.i][node2.j-1]))
					   	futureSquares++;
					else if(node2.isConnectedToB(board[node2.i][node2.j-1]) &&
							board[node2.i][node2.j-1].isConnectedToB(board[node1.i][node1.j-1]))
						futureSquares++;
					else if(node1.isConnectedToB(board[node1.i][node1.j-1]) &&
							node2.isConnectedToB(board[node2.i][node2.j-1]))
						futureSquares++;
				}
				if(node1.j < Constants.NUMBER_OF_DOTS - 1)
				{
					if(node1.isConnectedToB(board[node1.i][node1.j+1]) &&
					   board[node1.i][node1.j+1].isConnectedToB(board[node2.i][node2.j+1]))
					   	futureSquares++;
					else if(node2.isConnectedToB(board[node2.i][node2.j+1]) &&
							board[node2.i][node2.j+1].isConnectedToB(board[node1.i][node1.j+1]))
						futureSquares++;
					else if(node2.isConnectedToB(board[node2.i][node2.j+1]) &&
							node1.isConnectedToB(board[node1.i][node1.j+1]))
						futureSquares++;
				}
			}
			else
			{
				var min = node1.j < node2.j ? node1 : node2;
				node2 = node1.j > node2.j ? node1 : node2;
				node1 = min;
				if(node1.i > 0)
				{
					if(node1.isConnectedToB(board[node1.i-1][node1.j]) &&
					   board[node1.i-1][node1.j].isConnectedToB(board[node2.i-1][node2.j]))
					   	futureSquares++;
					else if(node2.isConnectedToB(board[node2.i-1][node2.j]) &&
							board[node2.i-1][node2.j].isConnectedToB(board[node1.i-1][node1.j]))
						futureSquares++;
					else if(node2.isConnectedToB(board[node2.i-1][node2.j]) &&
							node1.isConnectedToB(board[node1.i-1][node1.j]))
						futureSquares++;
				}
				if(node1.i < Constants.NUMBER_OF_DOTS - 1)
				{
					if(node1.isConnectedToB(board[node1.i+1][node1.j]) &&
					   board[node1.i+1][node1.j].isConnectedToB(board[node2.i+1][node2.j]))
					   	futureSquares++;
					else if(node2.isConnectedToB(board[node2.i+1][node2.j]) &&
							board[node2.i+1][node2.j].isConnectedToB(board[node1.i+1][node1.j]))
						futureSquares++;
					else if(node1.isConnectedToB(board[node1.i+1][node1.j]) &&
							node2.isConnectedToB(board[node2.i+1][node2.j]))
						futureSquares++;
				}
			}
			return futureSquares;
		}
	}
	
}
