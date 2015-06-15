package  
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
			var possibleEdges = getAllPossibleEdges();
			setAllHeuristics(possibleEdges);
			var edge = miniMax(possibleEdges, int.MIN_VALUE, int.MAX_VALUE, true);
			clickedDots = new Array(edge.getDot(), edge.getConnectedDot());
			dispatchEvent(new Event(Constants.CONNECT_DOTS_EVENT));
		}
		private function getAllPossibleEdges():Array
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
		private function setAllHeuristics(edges:Array)
		{
			var acHeur;
			for(var i:int = 0; i < edges.length; i++)
			{
				acHeur = heuristic(edges[i]);
				edges[i].setHeuristic(acHeur);
			}
		}
		private function miniMax(edges:Array, alfa:int, beta:int, maximizingPlayer:Boolean):Edge
		{
			/* terminal node here */
			var e = getTerminalEdgeIfExists(edges);
			if(e != null)
			{
				e.setHeuristic(heuristic(e));
				return e;
			}
			
			if(maximizingPlayer)
			{
				var v = getMax(edges);
				for(var i:int = 0; i < edges.length; i++)
				{
					if(!edges[i].gotVisited())
					{
						edges[i].setVisited(true);
						var mmax = miniMax(edges, alfa, beta, false);
						v =  v.getHeuristic() > mmax.getHeuristic() ? v : mmax;
						alfa = v.getHeuristic() > alfa ? v.getHeuristic() : alfa;
						if(beta <= alfa)
							break;
					}
				}
				v.setHeuristic(heuristic(v));
				return v;
				
			}
			else
			{
				var g = getMin(edges);
				for(var j:int = 0; j < edges.length; j++)
				{
					if(!edges[j].gotVisited())
					{
						edges[j].setVisited(true);
						var mmin = miniMax(edges, alfa, beta, true);
						g = g.getHeuristic() > mmin.getHeuristic() ? mmin : g;
						beta = g.getHeuristic() > beta ? beta : g.getHeuristic();
						if(beta <= alfa)
							break;
					}
				}
				g.setHeuristic(heuristic(g));
				return g;
			}
		}
		private function getTerminalEdgeIfExists(edges:Array):Edge
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
		
		/* Guarantee to node1(start edge) and node2(end edge) both be adjacent */
		
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
