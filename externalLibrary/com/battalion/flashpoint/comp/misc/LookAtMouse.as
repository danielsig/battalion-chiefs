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
		
		/**
		 * Set this to false to temporarily disable this component's behavior
		 */
		public var enabled : Boolean = true;
		
		/**
		 * A number to multiply the angular transition with, before applying it to the rotation.
		 * In other words, the rotation will become:
			 * <code>rotation += (targetRotation - rotation) * transitionMultiplier;</code>
		 */
		public var transitionMultiplier : Number = 0.9;
		
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
				if (transitionMultiplier <= 0 || transitionMultiplier > 1) throw new Error("transitionMultiplier must be a value between 0 and 1 (0 > x ≥ 1), but it was: " + transitionMultiplier);
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
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			_tr.rotateTowards(mousePos, angleOffset, transitionMultiplier * FlashPoint.deltaRatio);
			if (_tr.rotation < lowerConstraints) _tr.rotation = lowerConstraints;
			else if (_tr.rotation > upperConstraints) _tr.rotation = upperConstraints;
			_prevRotation = _tr.rotation;
		}
		
	}
	
}