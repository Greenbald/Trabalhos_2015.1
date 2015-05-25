package  
{
	import flash.display.*;
	public class Dot extends MovieClip
	{
		public var color:int; /* The player who has this dot */
		public var dot:DotAsset;
		public var i:int;
		public var j:int;
		public function Dot(i:int, j:int, dot:DotAsset) 
		{
			this.dot = dot;
			this.i = i;
			this.j = j;
			this.color = -1;
		}
		public function addChildren()
		{
			this.addChild(this.dot);
		}
	}
}
