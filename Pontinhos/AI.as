package  
{
	import flash.utils.Timer;
	import flash.events.*;
	import Player;	
	import Constants;
	import GameState;
	public class AI extends Player
	{
		private var dots:Array;
		public function AI(playerColor:Boolean) 
		{
			super(playerColor);
		}
		override public function init(dots:Array)
		{
			this.dots = dots;
		}
		override public function move_(dot:Dot){}
		
		override public function canMove()
		{
			var gameState = new GameState(dots);
			gameState = alphabeta(gameState, int.MIN_VALUE, int.MAX_VALUE, true);
			var edge = gameState.getSolution();
			clickedDots = new Array(dots[edge.getDot().i][edge.getDot().j]
									, dots[edge.getConnectedDot().i][edge.getConnectedDot().j]);
			dispatchEvent(new Event(Constants.CONNECT_DOTS_EVENT));
		}
		private function alphabeta(gameState:GameState, alfa:int, beta:int, maximizingPlayer:Boolean):GameState
		{
			/* terminal node here */
			if(gameState.getLegalMoves().length == 1)
			{
				var newGameStateTerminal = gameState.cloneGameState();
				newGameStateTerminal.addHaste(gameState.getLegalMoves()[0]);
				return newGameStateTerminal;
			}
			var gameStateClone = gameState.cloneGameState();
			var moves = gameStateClone.getLegalMoves();
			var bestValue;
			if(maximizingPlayer)
			{
				var maxHaste = null;
				bestValue = alfa;
				for(var i:int = 0; i < moves.length; i++)
				{
					gameStateClone.addHaste(moves[i]);
					var newGameStateMax = alphabeta(gameStateClone, alfa, beta, false);
					bestValue = Math.max(bestValue, eval(newGameStateMax));
					gameStateClone.removeHaste(moves[i]);
					if(bestValue > alfa)
					{
						alfa = bestValue;
						maxHaste = moves[i];
					}
					if(beta <= alfa)
						break; /* beta cut-off */
				}
				if(maxHaste != null)
					gameStateClone.addHaste(maxHaste);
				return gameStateClone;
			}
			else
			{
				var minHaste = null;
				bestValue = beta;
				for(var j:int = 0; j < moves.length; j++)
				{
					gameStateClone.addHaste(moves[j]);
					var newGameStateMin = alphabeta(gameStateClone, alfa, beta, true);
					bestValue = Math.min(bestValue, eval(newGameStateMin));
					gameStateClone.removeHaste(moves[j]);
					if(bestValue < beta)
					{
						beta = bestValue;
						minHaste = moves[j];
					}
					if(beta <= alfa)
						break; /* alfa cut-off */
				}
				if(minHaste != null)
					gameStateClone.addHaste(minHaste);
				return gameStateClone;
			}
		}
		private function eval(gameState:GameState):int
		{
			var edges = gameState.getLegalMoves();
			var heuristicValue:int = 0;
			for(var i:int = 0; i < edges.length; i++)
			{
				heuristicValue += heuristic(edges[i]);
			}
			return heuristicValue;
		}
		
		/* Guarantee which node1(start edge) and node2(end edge) both be adjacent */
		private function heuristic(edge:Edge):int
		{
			var node1:Dot, node2:Dot;
			node1 = edge.getDot();
			node2 = edge.getConnectedDot();
			/* node1 must have i equals to node2 and node1.j < node2.j when they're horizontal ,
			   node2 must have j equals to node2 and node1.i < node2.i when they're vertical */
			var heurValue:int = 0;
			
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
				    heurValue += 100;
				/* Check for a square below the haste */ 
				if(node1.i < Constants.NUMBER_OF_DOTS - 1 &&
				   node1.isConnectedToB(dots[node1.i+1][node1.j]) &&
				   node2.isConnectedToB(dots[node2.i+1][node2.j]) &&
				   dots[node1.i+1][node1.j].isConnectedToB(dots[node2.i+1][node2.j]))
				   	heurValue += 100;
				heurValue += -100*numberOfFutureSquares(node1, node2, false);
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
				   	heurValue += 100;
				/* Check for a square right the haste */
				if(node1.j < Constants.NUMBER_OF_DOTS - 1 &&
				   node1.isConnectedToB(dots[node1.i][node1.j+1]) && 
				   node2.isConnectedToB(dots[node2.i][node2.j+1]) &&
				   dots[node1.i][node1.j+1].isConnectedToB(dots[node2.i][node2.j+1]))
					heurValue += 100;	
				heurValue += -100*numberOfFutureSquares(node1, node2, true);
			}
			return heurValue;
		}
		public function numberOfFutureSquares(node1:Dot, node2:Dot, vertical:Boolean):int
		{
			var val:int = 0;
			if(vertical)
			{
				if(node1.j > 0)
				{
					if(node1.isConnectedToB(dots[node1.i][node1.j-1]) &&
					   dots[node1.i][node1.j-1].isConnectedToB(dots[node2.i][node2.j-1]))
					   	val += 1;
					else if(node2.isConnectedToB(dots[node2.i][node2.j-1]) &&
							dots[node2.i][node2.j-1].isConnectedToB(dots[node1.i][node1.j-1]))
						val += 1;
					else if(node1.isConnectedToB(dots[node1.i][node1.j-1]) &&
							node2.isConnectedToB(dots[node2.i][node2.j-1]))
						val += 1;
				}
				if(node1.j < Constants.NUMBER_OF_DOTS - 1)
				{
					if(node1.isConnectedToB(dots[node1.i][node1.j+1]) &&
					   dots[node1.i][node1.j+1].isConnectedToB(dots[node2.i][node2.j+1]))
					   	val += 1;
					else if(node2.isConnectedToB(dots[node2.i][node2.j+1]) &&
							dots[node2.i][node2.j+1].isConnectedToB(dots[node1.i][node1.j+1]))
						val += 1;
					else if(node2.isConnectedToB(dots[node2.i][node2.j+1]) &&
							node1.isConnectedToB(dots[node1.i][node1.j+1]))
						val += 1;
				}
			}
			else
			{
				if(node1.i > 0)
				{
					if(node1.isConnectedToB(dots[node1.i-1][node1.j]) &&
					   dots[node1.i-1][node1.j].isConnectedToB(dots[node2.i-1][node2.j]))
					   	val += 1;
					else if(node2.isConnectedToB(dots[node2.i-1][node2.j]) &&
							dots[node2.i-1][node2.j].isConnectedToB(dots[node1.i-1][node1.j]))
						val += 1;
					else if(node2.isConnectedToB(dots[node2.i-1][node2.j]) &&
							node1.isConnectedToB(dots[node1.i-1][node1.j]))
						val += 1;
				}
				if(node1.i < Constants.NUMBER_OF_DOTS - 1)
				{
					if(node1.isConnectedToB(dots[node1.i+1][node1.j]) &&
					   dots[node1.i+1][node1.j].isConnectedToB(dots[node2.i+1][node2.j]))
					   	val += 1;
					else if(node2.isConnectedToB(dots[node2.i+1][node2.j]) &&
							dots[node2.i+1][node2.j].isConnectedToB(dots[node1.i+1][node1.j]))
						val += 1;
					else if(node1.isConnectedToB(dots[node1.i+1][node1.j]) &&
							node2.isConnectedToB(dots[node2.i+1][node2.j]))
						val += 1;
				}
			}
			return val;
		}
	}
}
