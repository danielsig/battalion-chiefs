package com.danielsig
{
	/**
	 * @author Daniel Sig
	 */
	public class MathLite
	{
		public static function Clamp01(value : Number) : Number
		{
			if(value > 1)
			{
				return 1;
			}
			if(value < 0)
			{
				return 0;
			}
			return value;
		}
	}
}