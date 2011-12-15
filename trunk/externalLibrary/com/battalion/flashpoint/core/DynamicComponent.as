package com.battalion.flashpoint.core 
{
	import flash.utils.Dictionary;
	/**
	 * The DynamicComponent is like the Object class built into flash, except that it's a Component.
	 * To use the DynamicComponent there are 3 things you need to do:<pre>
		 * 1) Call the addDynamic() method on a GameObject.
		 * 2) pass a String to that function as the name, and a dynamic Object with properties and methods (methods are simply properties that reference a Function object).
		 * 3) Pass out from exposure to this sheer awesomeness.
</pre>	 * The third step is relativly easy since most often it comes naturally.
	 * @example Here's a simple example of how to do something when another GameObject is being destroyed:<listing version="3.0">
		 * other.addDynamic("destructionNotifier", {onDestroy:otherIsBeingDestroyed});
		 * ...
		 * private function otherIsBeingDestroyed() : Boolean
		 * {
		 * 	// do something here
		 * 	return false;
		 * }
		 * </listing>
	 * @see GameObject.addDynamic()
	 * @author Battalion Chiefs
	 */
	public dynamic final class DynamicComponent extends Component 
	{
		/** @private **/
		internal var _name : String;
		/** @private **/
		internal var _hidden : Boolean;
		
		public function get name() : String
		{
			return _name;
		}
		public function addFunction(functionName : String, callBack : Function, firstParamIsGameObject : Boolean = false) : void
		{
			if (firstParamIsGameObject)
			{
				var dynamicCaller : DynamicCallback = new DynamicCallback();
				dynamicCaller.callBack = callBack;
				dynamicCaller.gameObject = gameObject;
				this[functionName] = dynamicCaller.call;
			}
			else
			{
				this[functionName] = callBack;
			}
		}
		
	}

}