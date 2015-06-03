package 
{
	public class Constants 
	{
		/* Do not change these values, they're all set in Engine class. */
		public static var SCREEN_WIDTH:int;
		public static var SCREEN_HEIGHT:int;
		public static var NUMBER_OF_DOTS:int;
		public static var DOT_SIZE:int;
		public static var DOT_MAX_NEIGHBOURS:int;
		/* This is set in setupDots() in DotBoard class */
		public static var DOT_DISTANCE:int;
		public static var CHANGE_SCREEN_EVENT:String = "CHANGE_SCREEN_EVENT";
		public static var GO_BACK_MENU_EVENT:String = "GGO_BACK_MENU_EVENT";
		public static var CONNECT_DOTS_EVENT:String = "CONNECT_DOTS_EVENT";
		public static var GAME_OVER_EVENT:String = "GAME_OVER_EVENT";
		public static var IA_HEURISTIC:int;
	}
}
