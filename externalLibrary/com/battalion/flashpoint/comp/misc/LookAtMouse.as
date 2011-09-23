package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.Input;
	import flash.geom.Point;
	
	/**
	 * Rotates the <code>GameObject</code> every frame so that it looks towards the mouse, with an angle offset <code>angleOffset</code>.
	 * @author Battalion Chiefs
	 */
	public class LookAtMouse extends Component 
	{
		
		public var angleOffset : Number = 0;
		
		/** @private **/
		public function update() : void 
		{
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			(gameObject.transform as Transform).rotateTowards(mousePos, angleOffset);
		}
		
	}
	
}