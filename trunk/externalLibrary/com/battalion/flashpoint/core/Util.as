package com.battalion.flashpoint.core 
{
	
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	internal final class Util 
	{
		
		public static function isComponent(type : Class) : Boolean
		{
			return describeType(type).factory.extendsClass.(@type=="com.battalion.flashpoint.core::Component").length();
		}
		public static function isExclusive(type : Class) : Boolean
		{
			return describeType(type).factory.implementsInterface.(@type == "com.battalion.flashpoint.core::IExclusiveComponent").length();
		}
		public static function isConcise(type : Class) : Boolean
		{
			return describeType(type).factory.implementsInterface.(@type == "com.battalion.flashpoint.core::IConciseComponent").length();
		}
		
	}

}