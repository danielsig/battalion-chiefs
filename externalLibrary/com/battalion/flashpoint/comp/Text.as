package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.display.View;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class Text extends Component implements IExclusiveComponent
	{
		/** @private */
		public var text : String = null;
		/** @private */
		public var offset : Matrix = null;
		
		public function start() : void
		{
			View.addTextToView(this);
		}
		public function onDestroy() : Boolean
		{
			View.removeTextFromView(this);
			return false;
		}
	}

}