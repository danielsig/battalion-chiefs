package com.battalion.flashpoint.comp.tools 
{
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.flashpoint.core.*;
	
	/**
	 * Call the create function in order to see the exact location of the cursor in world coordinates.
	 * Given that you're only using one camera, that is, <code>world.cam</code>
	 * @author Battalion Chiefs
	 */
	public final class MouseLocation extends Component implements IExclusiveComponent 
	{
		
		public static function create(color : uint = 0) : void
		{
			new GameObject("mouseLocator", MouseLocation, FollowMouse, TextRenderer).mouseLocation.color = color;
		}
		
		private var _text : TextRenderer = null;
		public var color : uint = 0;
		
		/** @private **/
		public function awake() : void
		{
			requireComponent(FollowMouse);
			_text = requireComponent(TextRenderer) as TextRenderer;
			_text.width = 128;
			_text.setOffset(70, -8);
			_text.font = "arial";
			_text.color = color;
			_text.bold = true;
		}
		/** @private **/
		public function update() : void
		{
			_text.color = color;
			_text.text = "(" + gameObject.transform.gx.toPrecision(5) + ", " + gameObject.transform.gy.toPrecision(5) + ")"
		}
		
	}

}