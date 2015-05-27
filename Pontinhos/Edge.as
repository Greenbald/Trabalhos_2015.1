package  
{	
	import Dot;
	public class Edge 
	{
		public var connectedDot:Dot;
		public var color:Boolean;
		public function Edge(dot2:Dot, color:Boolean) 
		{
			this.connectedDot = dot2;
			this.color = color;
		}
	}	
}
