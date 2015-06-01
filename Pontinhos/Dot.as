﻿package  
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
		public function addEdge(dot:Dot, connectedDot:Dot, color:Boolean)
		{
			var edge = new Edge(dot, connectedDot);
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
				if(edges[n].getConnectedDot() == dot)
					return true;
			}
			return false;
		}
		public function isConnectedTo(i:int, j:int):Dot
		{
			for(var n in edges)
			{
				if(edges[n].getConnectedDot().i == i && edges[n].getConnectedDot().j == j)
				   return edges[n].getConnectedDot();
			}
			return null;
		}
	}
}
