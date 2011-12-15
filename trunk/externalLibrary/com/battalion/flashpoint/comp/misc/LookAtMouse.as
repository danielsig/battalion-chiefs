package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.Camera;
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
		
		/**
		 * Set this to false to temporarily disable this component's behavior
		 */
		public var enabled : Boolean = true;
		
		/**
		 * A number to multiply the angular transition with before applying it to the GameObject.
		 */
		public var speed : Number = 4;
		
		/**
		 * The lower rotational constraints of the GameObject relative to the parent GameObject.
		 * Handy for joints such as heads and arms that are looking/pointing at the mouse.
		 * @see #upperConstraints
		 */
		public var lowerConstraints : Number = -180;
		/**
		 * The upper rotational constraints of the GameObject relative to the parent GameObject.
		 * Handy for joints such as heads and arms that are looking/pointing at the mouse.
		 * @see #lowerConstraints
		 */
		public var upperConstraints : Number = 180;
		
		private var _tr : Transform = null;
		private var _prevRotation : Number = 0;
		
		/** @private **/
		public function awake() : void 
		{
			_tr = gameObject.transform;
		}
		
		/** @private **/
		public function update() : void 
		{
			CONFIG::debug
			{
				if (speed <= 0) throw new Error("speed must be greater than 0, but it was: " + speed);
				if (lowerConstraints < -180 || lowerConstraints > 180) throw new Error("lowerConstraints must be a value between -180 and 180 (-180 ≥ x ≥ 180), but it was: " + lowerConstraints);
				if (upperConstraints < -180 || upperConstraints > 180) throw new Error("upperConstraints must be a value between -180 and 180 (-180 ≥ x ≥ 180), but it was: " + upperConstraints);
			}
			if (enabled)
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
		}
		/** @private **/
		public function look() : void 
		{
			_tr.rotation = _prevRotation;
			var mainCam : Camera = Camera.mainCamera;
			if (mainCam)
			{
				var mousePos : Point = mainCam.screenToWorld(Input.mouse);
				_tr.rotateTowards(mousePos, angleOffset, speed * FlashPoint.deltaTime);
				if (_tr.rotation < lowerConstraints) _tr.rotation = lowerConstraints;
				else if (_tr.rotation > upperConstraints) _tr.rotation = upperConstraints;
			}
			_prevRotation = _tr.rotation;
		}
		
	}
	
}