package com.battalion.flashpoint.core 
{
	/**
	 * GO AWAY!!!
	 * @author Battalion Chiefs
	 * @private
	 */
	internal final class DynamicCallback 
	{
		
		public var callBack : Function;
		public var gameObject : GameObject;
		
		public function call(...args) : void
		{
			args.unshift(gameObject);
			callBack.apply(null, args);
		}
		
	}

}