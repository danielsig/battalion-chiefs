package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.Input;
	import flash.geom.Point;
	
	/**
	 * Rotates the <code>GameObject</code> every frame so that it looks towards the mouse, with an angle offset <code>angleOffset</code>.
	 * @author Battalion Chiefs
	 */
	public class LookAtMouse extends Component implements IExclusiveComponent
	{
		
		public var angleOffset : Number = 0;
		
		/**
		 * Determines if the rotation assigment is passive(true) or assertive (false)
		 * Passive will cause other assignments to the rotation to overrule this one.
		 * Assertive will cause the GameObject to look at the mouse even though other components assign a value to the rotation.
		 */
		public var passive : Boolean = false;
		
		private var _tr : Transform = null;
		
		/** @private **/
		public function awake() : void 
		{
			_tr = gameObject.transform;
		}
		
		/** @private **/
		public function update() : void 
		{
			if (passive)
			{
				sendBefore("LookAtMouse_look", "update");
			}
			else
			{
				sendAfter("LookAtMouse_look", "update");
			}
		}
		/** @private **/
		public function look() : void 
		{
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			_tr.rotateTowards(mousePos, angleOffset);
		}
		
	}
	
}