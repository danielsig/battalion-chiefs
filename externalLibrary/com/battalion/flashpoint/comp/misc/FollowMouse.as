package com.battalion.flashpoint.comp.misc 
{
	import com.battalion.flashpoint.core.*;
	import flash.geom.Point;
	
	/**
	 * Use this to make a GameObject follow the mouse (e.g. for a custom cursor)
	 * @author Battalion Chiefs
	 */
	public final class FollowMouse extends Component implements IExclusiveComponent 
	{
		
		/** @private **/
		public function update() : void
		{
			gameObject.transform.globalPosition = new Point(Transform.mouseWorldX, Transform.mouseWorldY);
		}
		
	}

}