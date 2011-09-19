package com.battalion.flashpoint.comp 
{
	
	import com.battalion.audio.AudioLoader;
	import com.battalion.audio.AudioPlayer;
	import com.battalion.flashpoint.core.*;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import com.danielsig.StringUtilPro;
	
	/**
	 * Audio Component, use this Component to load and play audio in your game.
	 * @author Battalion Chiefs
	 */
	public class Audio extends Component implements IExclusiveComponent
	{
		
		private static var _sounds : Object = { };
		
		private var _player : AudioPlayer = new AudioPlayer(null, 1, -1);
		private var _soundName : String;
		private var _playing : Boolean = false;
		
		public static function load(soundName : String, url : String) : void 
		{
			_sounds[soundName] = new AudioLoader(url).audioData;
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
		public function get currentSound() : String
		{
			return _soundName;
		}
		public function set currentSound(value : String) : void
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
		public function play(soundName : String = null, loops : int = 0) : void
		{
			if (soundName)
			{
				CONFIG::debug
				{
					if (!_sounds.hasOwnProperty(soundName)) throw new Error("The sound you are trying to play has not been loaded.");
				}
				_player.audioData = _sounds[soundName];
				_player.position = 0;
				_player.play();
			}
			else if (_player.isPlaying)
			{
				_player.play();
			}
			_player.loops = loops;
			_playing = true;
		}
		/**
		 * Stop playback.
		 */
		public function stop() : void
		{
			_player.stop();
			_playing = false;
		}
		public function fixedUpdate() : void
		{
			if (_playing)
			{
				var dist : Number = gameObject.transform.x - world.cam.transform.x;
				_player.panning = dist * 0.002;
				if (dist < 0) dist = -dist;
				var distY : Number = gameObject.transform.y - world.cam.transform.y;
				dist += (distY < 0 ? -distY : distY);
				_player.volume = 1 - dist * 0.0015;
			}
		}
		/**
		 * Jump to and play from position <code>millisec</code>.
		 * @param	millisec, the point in time to jump to and play from.
		 */
		public function gotoAndPlay(millisec : Number) : void
		{
			_player.position = millisec;
			_player.play();
		}
		/**
		 * Jump to <code>millisec</code> and stop playback.
		 * @param	millisec, the point in time to jump to.
		 */
		public function gotoAndStop(millisec : Number) : void
		{
			_player.position = millisec;
			_player.stop();
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
			_player.position = value;
		}
	}
	
}