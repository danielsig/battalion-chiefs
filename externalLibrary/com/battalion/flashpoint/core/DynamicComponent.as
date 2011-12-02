package com.battalion.flashpoint.core 
{
	/**
	 * The DynamicComponent is like the Object class built into flash, except that it's a Component.
	 * To use the DynamicComponent there are 3 things you need to do:
		 * 1) Call the addDynamic() method on a GameObject.
		 * 2) pass a String to that function as the name, and a dynamic Object with properties and methods (methods are simply properties that reference a Function object).
		 * 3) Pass out from exposure to this sheer awesomeness.
	 * The third step is relativly easy since most often it comes naturally.
	 * @example Here's a simple example of how to do something when another GameObject is being destroyed:<listing version="3.0">
		 * other.addDynamic("destructionNotifier", {onDestroy:otherIsBeingDestroyed});
		 * ...
		 * private function otherIsBeingDestroyed() : Boolean
		 * {
		 * 	//TODO do something here
		 * 	return false;
		 * }
		 * </listing>
	 * @see GameObject.addDynamic()
	 * @author Battalion Chiefs
	 */
	public dynamic final class DynamicComponent extends Component 
	{
		internal var _name : String;
		internal var _hidden : Boolean;
		
		public function get name() : String
		{
			return _name;
		}
		
	}

}