package com.battalion.flashpoint.comp.tools 
{
	import com.battalion.flashpoint.comp.TextRenderer;
	import com.battalion.flashpoint.comp.Camera;
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.Input;
	
	import com.danielsig.StringUtilPro;
	
	/**
	 * Use the getConsole() method to get the console.
	 * <p>
	 * Calling log and logOn when in relase mode, will spawn the Console and the logged message will be displayed there.
	 * </p>
	 * @author Battalion Chiefs
	 */
	public final class Console extends Component implements IExclusiveComponent 
	{
		public static const MODE_ALWAYS : uint = 0;
		public static const MODE_AUTO : uint = 1;
		public static const MODE_NEVER : uint = 2;
		
		public static function get mode() : uint
		{
			return _mode;
		}
		public static function set mode(value : uint) : void
		{
			if (value >= MODE_ALWAYS && value <= MODE_NEVER)
			{
				if (value == MODE_ALWAYS && _mode > MODE_ALWAYS)
				{
					getConsole();
				}
				_mode = value;
			}
		}
		
		private static var _mode : uint = CONFIG::debug ? MODE_ALWAYS : MODE_AUTO;
		
		
		private var _consoleObject : GameObject = null;
		private var _text : TextRenderer = null;
		private var _cam : Camera = null;
		private var _numLines : uint = 0;
		private var toLen : Function = StringUtilPro.toMinLength;
		
		public var color : uint = 0x000000;
		public var background : uint = 0x808080;
		
		private static var _instance : Console = null;
		private static var _createdUsingGetConsole : Boolean = false;
		
		public static function getConsole() : Console
		{
			if (_mode == MODE_NEVER || !GameObject.world || !GameObject.world.cam) return null;
			_createdUsingGetConsole = true;
			return _instance || GameObject.world.cam.addComponent(Console) as Console;
		}
		
		/** @private **/
		public function awake() : void
		{
			if (_instance || !_createdUsingGetConsole)
			{
				throw new Error("The Console class is a singleton, do NOT add a Console yourself, use the Console.getConsole() method instead.");
			}
			_instance = this;
			
			Input.addContextMenuItem("Hide Console");
			_cam = gameObject.camera as Camera;
			_consoleObject = new GameObject("consoleGameObject", gameObject, TextRenderer);
			_consoleObject.transform.x = -_cam.width * 0.5;
			_consoleObject.transform.y = _cam.height * 0.5;
			_consoleObject.transform.tweenPosition(_consoleObject.transform.x, _cam.height * 0.25, 1.5);
			_text = _consoleObject.textRenderer;
			_text.alpha = 0.75;
			_text.font = "courier";
			_text.color = color;
			_text.background = background;
			_text.bold = true;
			_text.wordWrap = false;
			_text.autoPosition = TextRenderer.AUTO_POSITION_TOP_LEFT;
			_text.autoSize = TextRenderer.AUTO_SIZE_NONE;
			_text.align = TextRenderer.ALIGN_JUSTIFY;
			_text.selectable = true;
			_text.restrict = "";
		}
		/** @private **/
		public function start() : void
		{
			_text.width = _cam.width * 0.708;
			_text.height = _cam.height * 0.5;
		}
		/** @private **/
		public function update() : void
		{
			_text.color = color;
			_text.background = background;
			if (!_text.text.length) _text.text = " ";
			if (Input.menuSelected("Hide Console"))
			{
				Input.removeContextMenuItem("Hide Console");
				Input.addContextMenuItem("Show Console");
				_consoleObject.transform.tweenPosition(_consoleObject.transform.x, _cam.height * 0.6);
			}
			else if (Input.menuSelected("Show Console"))
			{
				Input.removeContextMenuItem("Show Console");
				Input.addContextMenuItem("Hide Console");
				_consoleObject.transform.tweenPosition(_consoleObject.transform.x, _cam.height * 0.25);
			}
		}
		public static function writeLine(object : *, ...rest) : void
		{
			if (_mode == MODE_NEVER || !GameObject.world || !GameObject.world.cam) return;
			_createdUsingGetConsole = true;
			rest.unshift(object);
			(_instance || GameObject.world.cam.addComponent(Console) as Console).writeLine.apply(null, rest);
		}
		public function writeLine(object : *, ...rest) : void
		{
			var line : String = object.toString() + rest.join(" ");
			var lines : Array = line.split("\n");
			if (_numLines) _text.text += "\n " + lines.join("\n ");
			else _text.text += " " + lines.join("\n ");
			_numLines += lines.length;
			var index : int = 0;
			while (_numLines > 7)
			{
				_numLines--;
				index = _text.text.indexOf("\n", index)+1;
				if (!index)
				{
					_numLines = 1;
					index = _text.text.lastIndexOf("\n");
					break;
				}
			}
			if(index) _text.text = _text.text.slice(index);
			
			/*for each(var line : String in lines)
			{
				_textString += "\n" + toLen("$" + _numLines++, 4, " ") + " " + text;
			}*/
		}
		public static function clear() : void
		{
			if (_mode == MODE_NEVER || !GameObject.world || !GameObject.world.cam) return;
			_createdUsingGetConsole = true;
			(_instance || GameObject.world.cam.addComponent(Console) as Console).clear();
		}
		public function clear() : void
		{
			_text.text = " ";
		}
	}

}