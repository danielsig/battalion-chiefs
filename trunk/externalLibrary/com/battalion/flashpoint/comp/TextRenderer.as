package com.battalion.flashpoint.comp 
{
	CONFIG::flashPlayer10
	{
		import com.battalion.flashpoint.display.View;
	}
	CONFIG::flashPlayer11
	{
		import com.battalion.flashpoint.display.ViewFlash11;
	}
	
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.geom.Matrix;
	
	/**
	 * A Component that reprisents TextFields in flash.
	 * <p><pre>
	 * Messages sent:
		 * onTextInput(inputText : String)
			* sent <strong>before</strong> applying the user's input to the TextRenderer
		 * onTextChanged()
			* sent <strong>after</strong> the user's input has been applied to the TextRenderer
	 * </pre></p>
	 * @author Battalion Chiefs
	 */
	public class TextRenderer extends Component implements IExclusiveComponent, IOffsetableComponent
	{
		public static const AUTO_POSITION_CENTER : uint = 0;
		public static const AUTO_POSITION_TOP_LEFT : uint = 1;
		public static const AUTO_POSITION_TOP : uint = 2;
		public static const AUTO_POSITION_TOP_RIGHT : uint = 3;
		public static const AUTO_POSITION_RIGHT : uint = 4;
		public static const AUTO_POSITION_BOTTOM_RIGHT : uint = 5;
		public static const AUTO_POSITION_BOTTOM : uint = 6;
		public static const AUTO_POSITION_BOTTOM_LEFT : uint = 7;
		public static const AUTO_POSITION_LEFT : uint = 8;
		
		public static const AUTO_SIZE_NONE : String = TextFieldAutoSize.NONE;
		public static const AUTO_SIZE_LEFT : String = TextFieldAutoSize.LEFT;
		public static const AUTO_SIZE_RIGHT : String = TextFieldAutoSize.RIGHT;
		public static const AUTO_SIZE_CENTER : String = TextFieldAutoSize.CENTER;
		
		public static const ALIGN_JUSTIFY : String = TextFormatAlign.JUSTIFY;
		public static const ALIGN_LEFT : String = TextFormatAlign.LEFT;
		public static const ALIGN_RIGHT : String = TextFormatAlign.RIGHT;
		public static const ALIGN_CENTER : String = TextFormatAlign.CENTER;
		
		/**
		 * Whether this the text can be selected by the user or not.
		 */
		public var selectable : Boolean = false;
		/*
		 * Indicates the set of characters that a user can enter into the TextRenderer If the value of the
		 * restrict property is null, you can enter any character. If the value of
		 * the restrict property is an empty string, you cannot enter any character (default). If the value
		 * of the restrict property is a string of characters, you can enter only characters in
		 * the string into the TestRenderer. The string is scanned from left to right. You can specify a range by
		 * using the hyphen (-) character. Only user interaction is restricted; a script can put any text into the 
		 * TextRenderer. If the string begins with a caret (^) character, all characters are initially accepted and 
		 * succeeding characters in the string are excluded from the set of accepted characters. If the string does 
		 * not begin with a caret (^) character, no characters are initially accepted and succeeding characters in the 
		 * string are included in the set of accepted characters.The following example allows only uppercase characters, spaces, and numbers to be entered into
		 * a TextRenderer:
		 * my_txt.restrict = "A-Z 0-9";
		 * The following example includes all characters, but excludes lowercase letters:
		 * my_txt.restrict = "^a-z";
		 * You can use a backslash to enter a ^ or - verbatim. The accepted backslash sequences are \-, \^ or \\.
		 * The backslash must be an actual character in the string, so when specified in ActionScript, a double backslash
		 * must be used. For example, the following code includes only the dash (-) and caret (^):
		 * my_txt.restrict = "\\-\\^";
		 * The ^ can be used anywhere in the string to toggle between including characters and excluding characters.
		 * The following code includes only uppercase letters, but excludes the uppercase letter Q:
		 * my_txt.restrict = "A-Z^Q";
		 * You can use the \u escape sequence to construct restrict strings.
		 * The following code includes only the characters from ASCII 32 (space) to ASCII 126 (tilde).
		 * my_txt.restrict = "\u0020-\u007E";
		 */
		public var restrict : String = "";
		/**
		 * Set this property to false in case you don't want the Input class to be locked whenever the user selects this text.
		 * @see #selectable
		 * @see Input
		 */
		public var selectingLocksInput : Boolean = true;
		
		public var text : String = "";
		public var _prevText : String = null;
		/**
		 * Offset matrix
		 */
		public var offset : Matrix = null;
		public var width : Number = 50;
		public var height : Number = 20;
		public var wordWrap : Boolean = true;
		public var bold : Boolean = false;
		public var italic : Boolean = false;
		public var underline : Boolean = false;
		/**
		 * The transparency of the text, background and border
		 */
		public var alpha : Number = 1;
		//RGB format for specifying color: 0x000000
		/**
		 * The color of the text.
		 */
		public var color : uint = 0;
		/**
		 * The color of the background, a negative value means there's no background.
		 */
		public var background : int = -1;
		/**
		 * The color of the border, a negative value means there's no border.
		 */
		public var border : int = -1;
		/**
		 * The font family e.g. Verdana, Arial, Times etc.
		 */
		public var font : String = null;
		/**
		 * Text align
		 */
		public var align : String = ALIGN_CENTER;
		/**
		 * Automatic positioning of the whole TextRenderer relative to it's text (not bounds)
		 */
		public var autoPosition : uint = AUTO_POSITION_CENTER;
		/**
		 * Text size in pixels
		 */
		public var autoSize : String = AUTO_SIZE_NONE;
		/**
		 * Text size in pixels
		 */
		public var size : int = 12;
		/**
		 * See the htmlTest property of native flash TextFields, read about it <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/text/TextField.html#htmlText">here</a>.
		 */
		public var htmlText : String = null;
		/**
		 * Determines if the TextRenderer is multiline or not.
		 */
		public var multiline : Boolean = true;
		
		/**
		 * Easy way of setting an offset to the TextRenderer, relative to the GameObject.
		 * @param	x, the offset along the x-axis
		 * @param	y, the offset along the x-axis
		 * @param	scale, the scale of the text
		 */
		public function setOffset(x : Number, y : Number, scale : Number = 1) : void
		{
			offset = new Matrix(scale, 0, 0, scale, x, y);
		}
		public function scale(amount : Number) : void
		{
			if (!offset) offset = new Matrix(amount, 0, 0, amount, 0, 0);
			else
			{
				offset.a *= amount;
				offset.d *= amount;
			}
		}
		public function translate(x : Number, y : Number) : void
		{
			if (!offset) offset = new Matrix(1, 0, 0, 1, x, y);
			else
			{
				offset.tx += x;
				offset.ty += y;
			}
		}
		
		/** @private **/
		public function start() : void
		{
			CONFIG::flashPlayer10
			{
				View.addTextToView(this);
			}
			CONFIG::flashPlayer11
			{
				ViewFlash11.addTextToView(this);
			}
		}
		/** @private **/
		public function onDestroy() : Boolean
		{
			text = font = htmlText = null;
			offset = null;
			
			CONFIG::flashPlayer10
			{
				View.removeTextFromView(this);
			}
			CONFIG::flashPlayer11
			{
				ViewFlash11.removeTextFromView(this);
			}
			return false;
		}
	}

}