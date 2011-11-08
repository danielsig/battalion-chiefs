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
	public class TextRenderer extends Component implements IExclusiveComponent
	{
		public var text : String = null;
		public var offset : Matrix = null;
		public var width : Number = 50;
		public var height : Number = 20;
		public var wordWrap : Boolean = true;
		public var bold : Boolean = false;
		public var italic : Boolean = false;
		public var underline : Boolean = false;
		//RGB format for specifying color: 0x000000
		public var color : uint = 0;
		public var font : String = null;
		public var size : int = 12;
		public var htmlText : String = null;
		
		public function setOffset(x : Number, y : Number, scale : Number = 1) : void
		{
			offset = new Matrix(scale, 0, 0, scale, x, y);
		}
		
		/** @private **/
		public function start() : void
		{
			View.addTextToView(this);
		}
		/** @private **/
		public function onDestroy() : Boolean
		{
			View.removeTextFromView(this);
			return false;
		}
	}

}