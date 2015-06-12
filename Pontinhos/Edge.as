package  
{	
	import Dot;
	public class Edge 
	{
		private var dot1:Dot;
		private var dot2:Dot;
		private var visited:Boolean;
		public var heuristic:int;
		public function Edge(dot1, dot2:Dot) 
		{
			this.dot1 = dot1;
			this.dot2 = dot2;
			this.heuristic = 0;
		}
		public function getDot():Dot
		{
			return this.dot1;
		}
		public function getConnectedDot():Dot
		{
			return this.dot2;
		}
		public function setVisited(val:Boolean)
		{
			this.visited = val;
		}
		public function gotVisited():Boolean
		{
			return this.visited;
		}
		public function setHeuristic(h:int)
		{
			this.heuristic = h;
		}
		public function getHeuristic():int
		{
			return this.heuristic;
		}
	}	
}
