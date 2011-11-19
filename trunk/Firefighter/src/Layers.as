package  
{
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Layers 
	{
		
		public static const NONE : uint = 0;
		
		public static const OBJECTS_VS_OBJECTS : uint = 1;
		public static const OBJECTS_VS_FIRE : uint = 2;
		public static const OBJECTS_VS_WATER : uint = 4;
		public static const WATER_VS_FIRE : uint = 8;
		public static const STEAM_AND_SMOKE : uint = 16;
		
		public static const ALL : uint = uint.MAX_VALUE;
		
		public function Layers() 
		{
			throw new Error("This is a static class, do not instantiate it");
		}
		
	}

}