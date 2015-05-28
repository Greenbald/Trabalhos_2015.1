package  
{
	import flash.display.*;
	public class Dot extends MovieClip
	{
		public var dot:DotAsset;
		public var i:int;
		public var j:int;
		public var graph:int;
		private var edges:Array;
		public function Dot(i:int, j:int, dot:DotAsset, graph:int) 
		{
			this.dot = dot;
			this.i = i;
			this.j = j;
			this.graph = graph;
			edges = new Array();
		}
		public function addChildren()
		{
			this.addChild(this.dot);
		}
		public function removeChildrens()
		{
			this.removeChild(this.dot);
		}
		public function addEdge(connectedDot:Dot, color:Boolean)
		{
			var edge = new Edge(connectedDot, color);
			this.edges.push(edge);
		}
		public function getNumberOfNeighbours():int
		{
			return this.edges.length;
		}
		public function getEdges():Array
		{
			return this.edges;
		}
		public function isConnectedToB(dot:Dot):Boolean
		{
			for(var n in edges)
			{
				if(edges[n].connectedDot == dot)
					return true;
			}
			return false;
		}
		public function isConnectedTo(i:int, j:int):Dot
		{
			for(var n in edges)
			{
				if(edges[n].connectedDot.i == i && edges[n].connectedDot.j == j)
				   return edges[n].connectedDot;
			}
			return null;
		}
	}
}
