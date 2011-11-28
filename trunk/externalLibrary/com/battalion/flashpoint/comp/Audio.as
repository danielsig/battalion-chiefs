package com.battalion.flashpoint.comp 
{
	
	import com.battalion.audio.AudioLoader;
	import com.battalion.audio.AudioPlayer;
	import com.battalion.flashpoint.core.*;
	import flash.display.Stage;
	import flash.display.SWFVersion;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import com.danielsig.StringUtilPro;
	import flash.utils.ObjectInput;
	
	/**
	 * Audio Component, use this Component to load and play audio in your game.
	 * @author Battalion Chiefs
	 */
	public class Audio extends Component implements IExclusiveComponent, IPlayableComponent
	{
		
		private static var _sounds : Object = { };
		public static var audioListener : Transform = world.cam.transform;
		public static var volumeFalloff : Number = 0.0015;
		public static var panningMultiplier : Number = 1;
		public static var listenerZoomFactor : Number = 1;
		
		private var _player : AudioPlayer = new AudioPlayer();
		private var _soundName : String;
		private var _playing : Boolean = false;
		private var _transform : Transform;
		
		/** @private **/
		public function onDestroy() : Boolean 
		{
			_player.dispose();
			_player = null;
			_soundName = null;
			_transform = null;
			return false;
		}
		
		/** @private **/
		public function awake() : void 
		{
			_transform = gameObject.transform;
		}
		
		public static function load(soundName : String, url : String) : void 
		{
			_sounds[soundName] = new AudioLoader(url).audioData;
		}
		
		/**
		 * The stereo effect of the headphones setting.
		 */
		public static function get headphonesEffect() : Number
		{
			return AudioPlayer.headphonesEffect;
		}
		public static function set headphonesEffect(value : Number) : void 
		{
			AudioPlayer.headphonesEffect = value;
		}
		
		/**
		 * If true, the panning effect will be a delay between the left and right channels.
		 * If false, the panning effect will be a difference in volume between the left and right channels.
		 */
		public static function get useHeadphones() : Boolean
		{
			return AudioPlayer.headphones;
		}
		public static function set useHeadphones(value : Boolean) : void 
		{
			AudioPlayer.headphones= value;
		}
		/**
		 * Traces out currently loaded/loading sounds, their length in minutes/seconds/milliseconds, how much is loaded and finialy the url.
		 */
		public static function listSounds() : void
		{
			/*
			 * The ASDoc generator thinks I'm not using the STATIC class StringUtilPro
			 * since I don't instantiate it *facepalm*. So it refuses to generate
			 * docs unless I at least create this stupid variable. *facepalm*
			*/
			var hereYouGoStupidASDocs : StringUtilPro;
			trace("sounds\n{");
			for (var soundName : String in _sounds)
			{
				var millisec : Number = _sounds[soundName].length;
				var loadedMillisec : Number = _sounds[soundName].loadedLength;
				trace(StringUtilPro.toMinLength("\t" + soundName + "$", 20)
				+ "length: " + int(millisec * 0.0000166666667) + ":" + int(millisec * 0.001) + ":" + int(millisec % 1000)
				+ ", loaded: " + int(loadedMillisec * 0.0000166666667) + ":" + int(loadedMillisec * 0.001) + ":" + int(loadedMillisec % 1000));
			}
			trace("}");
		}
		
		/**
		 * current sound's name. Set this to change what sound is currently being played.
		 * @see #play()
		 */
		public function get currentName() : String
		{
			return _soundName;
		}
		public function set currentName(value : String) : void
		{
			CONFIG::debug
			{
				if (!_sounds.hasOwnProperty(value)) throw new Error("The sound you are trying to play has not been loaded.");
			}
			_soundName = value;
			_player.audioData = _sounds[_soundName];
			if (_playing)
			{
				_player.play();
			}
		}
		/**
		 * Resume playback/select sound to play.
		 * <p>
<pre>When resuming playback, leave the <code>soundName</code> parameter blank.
When selecting another sound, set the <code>soundName</code> to the desired sound. The sound will play starting from the beginning of the sound.</pre>
		 * </p>
		 * @see #currentAnimation
		 * @param soundName, the name if the sound to play, null simply resumes playback (default).
		 * @param loops, the number of loops to perform. 0 loops forever (default).
		 */
		public function play(soundName : String = null, loops : uint = 0) : void
		{
			_player.loops = loops;
			_playing = true;
			if (soundName && _soundName != soundName)
			{
				CONFIG::debug
				{
					if (!_sounds.hasOwnProperty(soundName)) throw new Error("The sound you are trying to play has not been loaded.");
				}
				_soundName = soundName;
				_player.audioData = _sounds[soundName];
				_player.position = 0;
				_player.play();
			}
			else if (!_player.isPlaying)
			{
				_player.play();
			}
		}
		/**
		 * Stop playback.
		 */
		public function stop() : void
		{
			_player.position = 0;
			_player.stop();
			_playing = false;
		}
		public function pause() : void
		{
			_player.stop();
			_playing = false;
		}
		public function fixedUpdate() : void
		{
			if (_playing)
			{
				var dist : Number = _transform.x - audioListener.x;
				_player.panning = dist * 0.002 * panningMultiplier / audioListener.scale;
				if (dist < 0) dist = -dist;
				var distY : Number = _transform.y - audioListener.y;
				dist += (distY < 0 ? -distY : distY);
				var volumeFactor : Number = ((1 - listenerZoomFactor) + listenerZoomFactor * audioListener.scale);
				_player.volume = (1 - dist * volumeFalloff * (0.5 - (2 / (2 + audioListener.scale)))) / volumeFactor;
			}
		}
		/**
		 * Jump to and play from position <code>millisec</code>.
		 * @param	millisec, the point in time to jump to and play from.
		 */
		public function gotoAndPlay(millisec : Number, soundName : String = null) : void
		{
			if (soundName && soundName != _soundName)
			{
				CONFIG::debug
				{
					if (!_sounds.hasOwnProperty(soundName)) throw new Error("The sound you are trying to play has not been loaded.");
				}
				_soundName = soundName;
				_player.audioData = _sounds[_soundName];
			}
			_playing = true;
			_player.position = millisec;
			_player.play();
		}
		/**
		 * Jump to <code>millisec</code> and stop playback.
		 * @param	millisec, the point in time to jump to.
		 */
		public function gotoAndPause(millisec : Number, soundName : String = null) : void
		{
			if (soundName && soundName != _soundName)
			{
				CONFIG::debug
				{
					if (!_sounds.hasOwnProperty(soundName)) throw new Error("The sound you are trying to play has not been loaded.");
				}
				_soundName = soundName;
				_player.audioData = _sounds[_soundName];
			}
			_playing = false;
			_player.position = millisec;
			_player.stop();
		}
		/**
		 * Determines if audio playback should reverse every time it reaches an end.
		 */
		public function get pingPongPlayback() : Boolean
		{
			return _player.pingPongPlayback;
		}
		public function set pingPongPlayback(value : Boolean) : void
		{
			_player.pingPongPlayback = value;
		}
		
		/**
		 * The direction of the audio playback relative to the original direction of the audio playback.
		 * A value of:
		 * <ul>
		 * <li>
		 * <code>true</code> means that the audio is played backwards.
		 * </li>
		 * <li>
		 * <code>false</code> means that the audio is played normally.
		 * </li>
		 * </ul>
		 */
		public function get reversed() : Boolean
		{
			return _player.reverse;
		}
		public function set reversed(value : Boolean) : void
		{
			_player.reverse = value;
		}
		
		public function get playing() : Boolean
		{
			return _playing;
		}
		public function set playing(value : Boolean) : void
		{
			if(_soundName) _playing = value;
		}
		
		/**
		 * The position of the playhead, in milliseconds.
		 */
		public function get playhead() : Number
		{
			return _player.position;
		}
		public function set playhead(value : Number) : void
		{
			CONFIG::debug
			{
				var length : Number = _player.audioData.length;
				if (value <= -length || value >= length) throw new Error("Can not set the playhead to " + value + " for it is out of range [" + -length + " - " + length + "]");
			}
			_player.position = value < 0 ? _player.audioData.length + value : value;
		}
		public function reverse() : void
		{
			_player.reverse = !_player.reverse;
		}
	}
	
}