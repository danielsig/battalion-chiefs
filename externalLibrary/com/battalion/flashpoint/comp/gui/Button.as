package com.battalion.flashpoint.comp.gui 
{
	/**
	 * 
	 * @author Battaion Chiefs
	 */
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.Input;
	import com.battalion.flashpoint.core.Transform;
	
	public class Button extends Component implements IExclusiveComponent
	{
		public var _buttonUp:String = _defaultButtonUp;
		public var _buttonDown:String = _defaultButtonDown;
		public var _buttonHover:String = _defaultButtonHover;
		
		private static var _defaultButtonUp:String;
		private static var _defaultButtonDown:String;
		private static var _defaultButtonHover:String;
		
		public var width:Number;
		public var height:Number;
		private var _renderer:Renderer;
		
		
		public function awake():void
		{
			_renderer = requireComponent(Renderer) as Renderer;
			width = 40;
			height = 20;
		}
		
		public static function defineDefault(buttonUp:String, buttonDown:String, buttonHover:String):void
		{
			_defaultButtonUp = buttonUp;
			_defaultButtonDown = buttonDown;
			_defaultButtonHover = buttonHover;
		}
		
		public function fixedUpdate():void
		{
			var top : Number = -height * 0.5;
			var bottom : Number = height * 0.5;
			var left : Number = -width * 0.5;
			var right : Number = width * 0.5;
			
			var x : Number = gameObject.transform.mouseRelativeX;
			var y : Number = gameObject.transform.mouseRelativeY;
			
			
			if ( (x > left && x < right) && (y > top && y < bottom))
			{
				if (Input.mouseHold)
				{
					_renderer.setBitmapByName(_buttonDown);
				}
				else
				{
					_renderer.setBitmapByName(_buttonHover);
				}
			} 
			else
			{
				_renderer.setBitmapByName(_buttonUp);
			}
			
		}
		
		
	}

}