package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.comp.TextRenderer;
	import com.battalion.flashpoint.core.*;
	
	/**
	 * Add this component and then send the "destroyer" message to destroy the whole GameObject.
	 * @author Battalion Chiefs
	 */
	public final class Destroyer extends Component implements IConciseComponent, IExclusiveComponent
	{
		/** @private **/
		public function destroyer() : void 
		{
			gameObject.destroy();
		}
		
	}
	
}