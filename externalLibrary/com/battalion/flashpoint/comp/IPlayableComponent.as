package com.battalion.flashpoint.comp 
{
	
	/**
	 * An interface for all playable components.
	 * @author Battalion Chiefs
	 */
	public interface IPlayableComponent 
	{
		function play(name : String = null, loops : uint = 0) : void;
		function pause() : void;
		function stop() : void;
		function reverse() : void;
		function gotoAndPlay(time : Number, name : String = null) : void;
		function gotoAndPause(time : Number, name : String = null) : void;
		function get playhead() : Number;
		function set playhead(value : Number) : void;
		function get pingPongPlayback() : Boolean;
		function set pingPongPlayback(value : Boolean) : void;
		function get currentName() : String;
		function set currentName(value : String) : void;
		function get reversed() : Boolean;
		function set reversed(value : Boolean) : void;
	}
	
}