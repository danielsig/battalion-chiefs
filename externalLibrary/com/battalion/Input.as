package com.battalion 
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.Keyboard;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import net.onthewings.utils.KeyCodeUtil;
	import com.danielsig.StringUtilPro;
	
	/**
	 * An input class, useful in almost any situation where user input is required.
	 * @author Battalion Chiefs
	 */
	public final class Input 
	{
		
		private static var _prevKeyCounter : int = 0;
		private static var _prevKeys : Vector.<int> = new Vector.<int>(256);
		
		private static var _press : Vector.<Boolean> = new Vector.<Boolean>(256);
		private static var _release : Vector.<Boolean> = new Vector.<Boolean>(256);
		private static var _hold : Vector.<Boolean> = new Vector.<Boolean>(256);
		private static var _toggled : Vector.<Boolean> = new Vector.<Boolean>(256);
		private static var _buttons : Dictionary = new Dictionary();
		
		private static var _mouseButton : int = 0;
		private static var _scroll : int = 0;
		private static var _mouseX : Number = 0;
		private static var _mouseY : Number = 0;
		
		private static var _mouseXPrev : Number = 0;
		private static var _mouseYPrev : Number = 0;
		
		private static var _stage : Stage;
		private static var _menu : ContextMenu;
		private static var _menuSelect : Dictionary = new Dictionary();
		private static var _enabled : Boolean = true;
		
		/**
		 * Use this to initialize. If your game logic loops does not happen on every frame,
		 * then it's recommended that you pass a <code>tickDispatcher</code> and a <code>tickEvent</code>.
		 * An example of such would be a <code>Timer</code> object as the <code>tickDispatcher</code> and a
		 * <code>TimerEvent.TIMER</code> as the <code>tickEvent</code>.
		 * @param	stage, you must pass the Stage object to this.
		 * @param	tickDispatcher, use this if your game logic loops are not performed on every frame (optional)
		 * @param	tickEvent, use this if your game logic loops are not performed on every frame (optional)
		 */
		public static function init(stage : Stage, tickDispatcher : EventDispatcher = null, tickEvent : String = "") : void
		{
			_stage = stage;
			if (!tickDispatcher) stage.addEventListener(Event.ENTER_FRAME, onNewFrame);
			else tickDispatcher.addEventListener(tickEvent, onNewFrame);
			unlock();
			
			_menu = new ContextMenu();
			_menu.hideBuiltInItems();
			_stage.showDefaultContextMenu = false;
			var index : uint = 0;
			do
			{
				var child : DisplayObject = _stage.getChildAt(index);
				if (child is InteractiveObject)
				{
					(child as InteractiveObject).contextMenu = _menu;
					return;
				}
			}
			while (++index < _stage.numChildren);
		}
		private static function onMouseDown(e : MouseEvent) : void	 { _mouseButton = 2; }
		private static function onMouseUp(e : MouseEvent) : void	 { _mouseButton = -1; }
		private static function onClick(e : MouseEvent) : void		 { _mouseButton = 3; }
		private static function onDoubleClick(e : MouseEvent) : void { _mouseButton = 4; }
		private static function onScroll(e : MouseEvent) : void 	 { _scroll = e.delta; }
		
		
		private static function onNewFrame(e : Event) : void
		{
			while(_prevKeyCounter)
			{
				_press[_prevKeys[--_prevKeyCounter]] = false;
				_release[_prevKeys[_prevKeyCounter]] = false;
			}
			if (_mouseButton > 0 && _mouseButton < 3) _mouseButton = 1;
			else _mouseButton = 0;
			
			_mouseXPrev = _mouseX;
			_mouseYPrev = _mouseY;
			if (_enabled)
			{
				_mouseX = _stage.mouseX;
				_mouseY = _stage.mouseY;
			}
			
			_scroll = 0;
			for (var menu : String in _menuSelect)
			{
				_menuSelect[menu] = false;
			}
		}
		private static function onKeyDown(e : KeyboardEvent) : void
		{
			_toggled[e.keyCode] = !_toggled[e.keyCode];
			_press[e.keyCode] = !_hold[e.keyCode];
			_hold[e.keyCode] = true;
			_prevKeys[_prevKeyCounter++] = e.keyCode;
		}
		private static function onKeyUp(e : KeyboardEvent) : void
		{
			_hold[e.keyCode] = false;
			_release[e.keyCode] = true;
		}
		
		public static function get mousePress() : Boolean 		{ return _mouseButton > 1; }
		public static function get mouseHold() : Boolean 		{ return _mouseButton == 1 || _mouseButton == 2; }
		public static function get mouseRelease() : Boolean 	{ return _mouseButton < 0; }
		public static function get mouseClick() : Boolean 		{ return _mouseButton > 2; }
		public static function get mouseDoubleClick() : Boolean { return _mouseButton == 4; }
		public static function get scrolling() : Boolean 		{ return _scroll as Boolean; }
		public static function get scroll() : int 				{ return _scroll; }
		
		public static function get mouseX() : Number 			{ return _mouseX; }
		public static function get mouseY() : Number 			{ return _mouseY; }
		
		public static function get stageWidth() : Number 			{ return _stage.stageWidth; }
		public static function get stageHeight() : Number 			{ return _stage.stageHeight; }
		
		public static function get mouseXPrevious() : Number 	{ return _mouseXPrev; }
		public static function get mouseYPrevious() : Number 	{ return _mouseYPrev; }
		public static function get mouseXMove() : Number 	{ return _mouseX - _mouseXPrev; }
		public static function get mouseYMove() : Number 	{ return _mouseY - _mouseYPrev; }
		
		public static function get mouse() : Point 			{ return new Point(_mouseX, _mouseY); }
		public static function get mousePrevious() : Point 	{ return new Point(_mouseXPrev, _mouseYPrev); }
		public static function get mouseMove() : Point 	{ return new Point(_mouseX - _mouseXPrev, _mouseY - _mouseYPrev); }
		
		public static function hold(keycode : int) : Boolean 	{ return _hold[keycode]; }
		public static function press(keycode : int) : Boolean 	{ return _press[keycode]; }
		public static function release(keycode : int) : Boolean { return _release[keycode]; }
		public static function toggled(keycode : int) : Boolean { return _toggled[keycode]; }
		
		public static function holdButton(name : String) : Boolean { return getButtons(name, _hold); }
		public static function pressButton(name : String) : Boolean { return getButtons(name, _press); }
		public static function releaseButton(name : String) : Boolean	{ return getButtons(name, _release); }
		public static function toggledButton(name : String) : Boolean
		{
			var i : int = _buttons[name + "NumAlt"];
			var value : Boolean = _toggled[_buttons[name]];
			while (i)
			{
				if (_toggled[_buttons[name + "Alt" + (--i)]]) value = !value;
			}
			return value;
		}
		private static function getButtons(name : String, arr : Vector.<Boolean>) : Boolean
		{
			var i : int = _buttons[name + "NumAlt"];
			var value : Boolean = arr[_buttons[name]];
			while (i)
			{
				if (!value) value = arr[_buttons[name + "Alt" + (--i)]];
				else break;
			}
			return value;
		}
		
		public static function directional(name : String) : int
		{
			return int(holdButton(name + "Positive")) - int(holdButton(name + "Negative"));
		}
		
		public static function assignButton(name : String, key : *, ...alternatives) : void
		{
			if (key is int) _buttons[name] = key as int;
			else _buttons[name] = KeyCodeUtil.keyCodeOf(key);
			
			var i : int = 0;
			for each(key in alternatives)
			{
				if (key is int) _buttons[name + "Alt" + i++] = key as int;
				else _buttons[name + "Alt" + i++] = KeyCodeUtil.keyCodeOf(key);
			}
			_buttons[name + "NumAlt"] = i;
		}
		public static function assignDirectional(name : String, positiveKey : *, negativeKey : *, ...alternatives) : void
		{
			CONFIG::debug
			{
				if (alternatives.length % 2 == 1) throw new Error("There must be an even number of alternatives.");
			}
			
			var positive : Array = new Array((alternatives.length >> 1) + 2);
			var negative : Array = new Array((alternatives.length >> 1) + 2);
			
			var i : int = alternatives.length;
			while (i)
			{
				negative[(--i >> 1) + 2] = alternatives[i];
				positive[(--i >> 1) + 2] = alternatives[i];
			}
			positive[0] = name + "Positive";
			positive[1] = positiveKey;
			negative[0] = name + "Negative";
			negative[1] = negativeKey;
			assignButton.apply(null, positive);
			assignButton.apply(null, negative);
		}
		public static function addContextMenuItem(name : String, sepperatorAbove : Boolean = false) : void
		{
			var item : ContextMenuItem = new ContextMenuItem(name, sepperatorAbove, true, true);
			_menu.customItems.push(item);
			_menuSelect[name] = false;
			item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuSelected);
		}
		public static function removeContextMenuItem(name : String) : void
		{
			for (var i : uint = 0; i < _menu.customItems.length; i++ )
			{
				if (_menu.customItems[i].caption == name)
				{
					_menu.customItems.splice(i, 1);
					delete _menuSelect[name]
					return;
				}
			}
		}
		public static function menuSelected(name : String) : Boolean
		{
			return _menuSelect[name];
		}
		private static function onMenuSelected(e:ContextMenuEvent) : void
		{
			_menuSelect[e.target.caption] = true;
		}
		
		/**
		 * Disables all input except context menu input and returns the only function that can enable it again.
		 * The returned method essentially works like a key to a lock, only the one who has a reference to this
		 * method can unlock the input again.
		 */
		public static function getLock() : Function
		{
			_enabled = false;
			if (_mouseButton == 1 || _mouseButton == 2) _mouseButton = -1;
			_scroll = 0;
			while(_prevKeyCounter)
			{
				_press[_prevKeys[--_prevKeyCounter]] = false;
				_release[_prevKeys[_prevKeyCounter]] = false;
				_hold[_prevKeys[_prevKeyCounter]] = false;
			}
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.removeEventListener(MouseEvent.CLICK, onClick);
			_stage.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			_stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
			
			return unlock;
		}
		private static function unlock(e : Event = null) : void
		{
			_enabled = true;
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_stage.addEventListener(MouseEvent.CLICK, onClick);
			_stage.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			_stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
		}
		
		public static function listButtons() : void
		{
			/*
			 * The ASDoc generator thinks I'm not using the STATIC class StringUtilPro
			 * since I don't instantiate it *facepalm*. So it refuses to generate
			 * docs unless I at least create this stupid variable. *facepalm*
			*/
			var hereYouGoStupidASDocs : StringUtilPro;
			
			trace("buttons\n{");
			for(var button : String in _buttons)
			{
				if (button.lastIndexOf("NumAlt") != button.length - 6)
					trace("\t" + StringUtilPro.toMinLength(button + "$", 30, ".") + ".keycode: " + _buttons[button]);
			}
			trace("}");
		}
	}

}