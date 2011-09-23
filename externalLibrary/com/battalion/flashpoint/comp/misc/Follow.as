package com.battalion.flashpoint.comp.misc 
{
	
	import com.battalion.flashpoint.core.*;
	import flash.geom.Point;
	
	/**
	 * A component that let's this GameObject follow another <code>target</code> GameObject's transform with a given <code>speed</code>.
	 * @author Battalion Chiefs
	 */
	public class Follow extends Component implements IExclusiveComponent
	{
		
		public var target : Transform = null;
		public var offset : Point = new Point(0, 0);
		public var speed : Number = 0.1;
		private var _transform : Transform;
		
		public function follow(target : GameObject, speed : Number = 0.1, offset : Point = null) : void 
		{
			this.target = target.transform;
			this.speed = speed;
			if(offset) this.offset = offset;
		}
		
		/** @private **/
		public function awake() : void 
		{
			_transform = gameObject.transform;
		}
		
		/** @private **/
		public function update() : void 
		{
			if (target)
			{
				CONFIG::debug
				{
					if (!offset) throw new Error("The offset must be non-null.");
					if (isNaN(speed)) throw new Error("Speed is NaN(Not a Number)!");
				}
				_transform.x += (offset.x + target.x - _transform.x) * speed;
				_transform.y += (offset.y + target.y - _transform.y) * speed;
			}
		}
		
	}
	
}