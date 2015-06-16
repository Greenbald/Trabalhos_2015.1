﻿package  
{
	import flash.utils.Timer;
	import flash.events.*;
	import Player;	
	import Constants;
	import GameBoardAI;
	public class AI extends Player
	{
		private var dots:Array;
		private var board:GameBoardAI;
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
			board = new GameBoardAI(dots);
			var possibleMoves = getAllPossibleMoves();
			var edge;
			/*if(possibleMoves > 10)
				edge = hillClimbing(possibleMoves);
			else*/
			edge = alphabeta(possibleMoves, int.MIN_VALUE, int.MAX_VALUE, true, true);
			clickedDots = new Array(edge.getDot(), edge.getConnectedDot());
			dispatchEvent(new Event(Constants.CONNECT_DOTS_EVENT));
		}
		private function getAllPossibleMoves():Array
		{
			var edges = new Array();
			for(var i:int = 0; i < dots.length; i++)
			{
				for(var j:int = 0; j < dots[i].length; j++)
				{
					if(j < Constants.NUMBER_OF_DOTS - 1)
					{
						if(!dots[i][j].isConnectedToB(dots[i][j+1]))
							edges.push(new Edge(dots[i][j], dots[i][j+1]));
					}
					if(i < Constants.NUMBER_OF_DOTS - 1)
					{
						if(!dots[i][j].isConnectedToB(dots[i+1][j]))
							edges.push(new Edge(dots[i][j], dots[i+1][j]));
					}
				}
			}
			return edges;
		}
/*		private function setAllHeuristics(edges:Array)
		{
			var acHeur;
			for(var i:int = 0; i < edges.length; i++)
			{
				acHeur = heuristic(edges[i]);
				edges[i].setHeuristic(acHeur);
			}
		}*/
		private function alphabeta(edges:Array, alfa:int, beta:int, turn:Boolean, maximizingPlayer:Boolean):Edge
		{
			var e = getLastMove(edges);
			if(e != null)
			{
				board.bestScore = board.scoreBoard[maximizingPlayer] - board.scoreBoard[!maximizingPlayer];
				return e;
			}
			var bestScore:int;
			var bestMove:Edge = getNextEdge(edges);
			if(maximizingPlayer)
			{
				bestScore = int.MIN_VALUE;
				for(var i:int = 0; i < edges.length; i++)
				{
					if(!edges[i].gotVisited())
					{
						turn = board.executeMove(edges[i], turn);
						alphabeta(edges, alfa, beta, maximizingPlayer,maximizingPlayer);
						turn = board.unexecuteMove(edges[i], maximizingPlayer);
						bestMove = board.bestScore > bestScore ? edges[i] : bestMove;
						bestScore = Math.max(board.bestScore, bestScore);
						alfa = bestScore;
						if(beta <= alfa)
							break;
					}
				}
				
			}
			else
			{
				bestScore = int.MAX_VALUE;
				for(var j:int = 0; j < edges.length; j++)
				{
					if(!edges[j].gotVisited())
					{
						turn = board.executeMove(edges[j], turn);
						alphabeta(edges, alfa, beta, turn,maximizingPlayer);
						turn = board.unexecuteMove(edges[j], turn);
						bestMove = board.bestScore < bestScore ? edges[j] : bestMove;
						bestScore = Math.min(board.bestScore, bestScore);
						beta = bestScore;
						if(beta <= alfa)
							break;
					}
				}
			}
			board.bestScore = bestScore;
			return bestMove;
		}
		
		private function getLastMove(edges:Array):Edge
		{
			var position:int = -1;
			var counter:int = 0;
			for(var i:int = 0; i < edges.length; i++)
			{
				if(!edges[i].gotVisited())
				{
					position = i;
					counter++;
				}
			}
			if(counter == 1)
				return edges[position];
			return null;
		}
		
		public function getNextEdge(edges:Array):Edge
		{
			for(var j:int = 0; j < edges.length; j++)
			{
				if(!edges[j].gotVisited())
					return edges[j];
			}
			return null;
		}
		
		/* It checks for a square that will be closed in the next turn, based on the move of the actual turn */ 
		public function checkFutureSquare(node1:Dot, node2:Dot, vertical:Boolean):Boolean
		{
			if(vertical)
			{
				if(node1.j > 0)
				{
					if(node1.isConnectedToB(dots[node1.i][node1.j-1]) &&
					   dots[node1.i][node1.j-1].isConnectedToB(dots[node2.i][node2.j-1]))
					   	return true;
					else if(node2.isConnectedToB(dots[node2.i][node2.j-1]) &&
							dots[node2.i][node2.j-1].isConnectedToB(dots[node1.i][node1.j-1]))
						return true;
					else if(node1.isConnectedToB(dots[node1.i][node1.j-1]) &&
							node2.isConnectedToB(dots[node2.i][node2.j-1]))
						return true;
				}
				if(node1.j < Constants.NUMBER_OF_DOTS - 1)
				{
					if(node1.isConnectedToB(dots[node1.i][node1.j+1]) &&
					   dots[node1.i][node1.j+1].isConnectedToB(dots[node2.i][node2.j+1]))
					   	return true;
					else if(node2.isConnectedToB(dots[node2.i][node2.j+1]) &&
							dots[node2.i][node2.j+1].isConnectedToB(dots[node1.i][node1.j+1]))
						return true;
					else if(node2.isConnectedToB(dots[node2.i][node2.j+1]) &&
							node1.isConnectedToB(dots[node1.i][node1.j+1]))
						return true;
				}
			}
			else
			{
				if(node1.i > 0)
				{
					if(node1.isConnectedToB(dots[node1.i-1][node1.j]) &&
					   dots[node1.i-1][node1.j].isConnectedToB(dots[node2.i-1][node2.j]))
					   	return true;
					else if(node2.isConnectedToB(dots[node2.i-1][node2.j]) &&
							dots[node2.i-1][node2.j].isConnectedToB(dots[node1.i-1][node1.j]))
						return true;
					else if(node2.isConnectedToB(dots[node2.i-1][node2.j]) &&
							node1.isConnectedToB(dots[node1.i-1][node1.j]))
						return true;
				}
				if(node1.i < Constants.NUMBER_OF_DOTS - 1)
				{
					if(node1.isConnectedToB(dots[node1.i+1][node1.j]) &&
					   dots[node1.i+1][node1.j].isConnectedToB(dots[node2.i+1][node2.j]))
					   	return true;
					else if(node2.isConnectedToB(dots[node2.i+1][node2.j]) &&
							dots[node2.i+1][node2.j].isConnectedToB(dots[node1.i+1][node1.j]))
						return true;
					else if(node1.isConnectedToB(dots[node1.i+1][node1.j]) &&
							node2.isConnectedToB(dots[node2.i+1][node2.j]))
						return true;
				}
			}
			return false;
		}
	}
}
