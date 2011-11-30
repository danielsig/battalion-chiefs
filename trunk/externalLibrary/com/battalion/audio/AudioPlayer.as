package com.battalion.audio 
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/**
	 * An AudioPlayer object can play Audio from an AudioData object.
	 * 
	 * @see AudioLoader
	 * @see AudioData
	 * 
	 * @author Battalion Chiefs
	 */
	public final class AudioPlayer 
	{
		
		public static const SAMPLES_PER_CALLBACK:int = 4000; // Should be >= 2048 && <= 8192
		
		/**
		 * If true, the panning effect will be a delay between the left and right channels.
		 * If false, the panning effect will be a difference in volume between the left and right channels.
		 */
		private static var _headphones : Boolean = false;
		/**
		 * The stereo effect of the headphones setting.
		 */
		public static var headphonesEffect : Number = 512;
		private static var _players : Vector.<AudioPlayer> = new Vector.<AudioPlayer>();
		private static var _mute : SoundTransform = new SoundTransform(0, 0);
		/**
		 * TimeScale to apply to all AudioPlayers.
		 */
		public static var globalTimeScale : Number = 1;

		/**
		 * TimeScale that is applied to only this AudioPlayer.
		 */
		public var timeScale : Number = 1;
		
		/**
		 * Determines if audio playback should reverse every time it reaches an end.
		 */
		public var pingPongPlayback : Boolean = false;
		
		private var _data : AudioData = null;
		
		private var _transform : SoundTransform = null;
		private var _pan : Number = 0;
		
		private var _p : uint = 0;
		private var _start : uint = 0;
		private var _end : uint = uint.MAX_VALUE;
		private var _reverse : Boolean = false;
		
		private var _loops : int = 0;
		
		private var _sound:Sound = null;
		private var _channel:SoundChannel = null;
		private var _playing : Boolean = false;
		private var _sampling : Boolean = false;

		public function get isPlaying() : Boolean
		{
			return _channel != null;
		}
		
		/**
		 * Determines if audio playback is reversed (played backwards).
		 */
		public function get reverse() : Boolean
		{
			return _reverse;
		}
		public function set reverse(value : Boolean) : void
		{
			_reverse = value;
			/*if (_reverse && _p == _start)
			{
				_p = _end;
			}
			else if (!_reverse && _p == _end)
			{
				_p = _start;
			}*/
		}
		
		/**
		 * The AudioData to play, set this to play a different audio.
		 * Note, every time you assign an audioData, the playerhead will
		 * return to the beginning of the audio.
		 */
		public function get audioData() : AudioData
		{
			return _data;
		}
		public function set audioData(value : AudioData) : void
		{
			_data = value;
			_start = _data._start * 705.6;
			if (_data._end == Number.MAX_VALUE) _end = uint.MAX_VALUE;
			else _end = _data._end * 705.6;
			
			_p = _start = (_start >>> 3) << 3;
			_end = (_end >>> 3) << 3;
			stop();
		}
		/**
		 * The number of loops to perform, 0 plays forever, 1 plays once, 2 plays twice etc.
		 * Use this to identify how many loops are left.
		 */
		public function get loops() : Number
		{
			return _loops;
		}
		public function set loops(value : Number) : void
		{
			_loops = value;
			if (!_loops)
			{
				_loops--;
			}
			else if (_reverse && _loops > 0) _loops++;
		}
		/**
		 * The position of the playhead, in milliseconds.
		 */
		public function get position() : Number
		{
			return ((_p - _start) >>> 3) / 44.1;
		}
		public function set position(value : Number) : void
		{
			_p = _start + ((value * 44.1) << 3);
		}
		/**
		 * Volume of this AudioPlayer.
		 */
		public function get volume() : Number
		{
			return _transform.volume;
		}
		public function set volume(value : Number) : void
		{
			if (value > 1) value = 1;
			else if (value < 0) value = 0;
			
			_transform.volume = value;
			if (_channel) _channel.soundTransform = _transform;
		}
		/**
		 * A Number between -1 and 1, -1 is to the far left, 0 is center, 1 is to the far right.
		 * 
		 * @see #headphones
		 */
		public function get panning() : Number
		{
			return _headphones ? _pan : _transform.pan;
		}
		public function set panning(value : Number) : void
		{
			if (value > 1) value = 1;
			else if (value < -1) value = -1;
			
			if (_headphones)
			{
				_pan = value;
				_transform.pan = value * value * 0.15;//falloff
			}
			else
			{
				_transform.pan = value;
				if (_channel) _channel.soundTransform = _transform;
			}
		}
		/**
		 * A boolean specifying what kind of stereo setting to use.
		 * <ul>
		 * <li>
		 * False is speaker setting which is designed for speakers where panning is simulated using <b>volume control</b> of the left-right channels.
		 * </li>
		 * <li>
		 * True is headphones setting which is designed for headphones where panning is simulated using <b>delay</b> in the left-right channels.
		 * </li>
		 * </ul>
		 * @see #panning
		 */
		public static function get headphones() : Boolean
		{
			return _headphones;
		}
		public static function set headphones(value : Boolean) : void
		{
			if (_headphones != value)//if changing...
			{
				if (value)//... to headphones
				{
					for each(var player : AudioPlayer in _players)
					{
						player._pan = player._transform.pan;
						player._transform.pan = 0;
					}
				}
				else//.. to speakers
				{
					for each(player in _players)
					{
						player._transform.pan = player._pan;
						player._pan = 0;
					}
				}
			}
			_headphones = value;
		}
		
		
		public function AudioPlayer(audioData : AudioData = null, volume : Number = 1, panning : Number = 0, loops : int = 0)
		{
			_players.push(this);
			
			_loops = loops;
			if (!_loops)
			{
				_loops--;
			}
			
			if (audioData)
			{
				_data = audioData;
				_start = _data._start * 705.6;
				if (_data._end == Number.MAX_VALUE) _end = uint.MAX_VALUE;
				else _end = _data._end * 705.6;
			}
			
			_p = _start;
			_sound = new Sound();
			timeScale = 1;
			if (_headphones)
			{
				_pan = panning;
				panning = 0;
			}
			_transform = new SoundTransform(volume, panning);
		}
		/**
		 * You must call this when you're done using this AudioPlayer, unless you really want your application to leak memory.
		 */
		public function dispose() : void
		{
			_players.splice(_players.indexOf(this), 1);
			_data = null;
			_transform = null;
		}
		/**
		 * Play AudioData.
		 * @param newData, the new AudioData to play
		 */
		public function play(newData : AudioData = null) : void
		{
			if (newData)
			{
				_data = newData;
				_p = _start = _data._start * 705.6;
				if (_data._end == Number.MAX_VALUE) _end = uint.MAX_VALUE;
				else _end = _data._end * 705.6;
				
				_start -= _start % 8;
				_end -= _end % 8;
				
			}
			if (!_playing && _data)
			{
				if (_reverse && _loops > 0) _loops++;
				_playing = _sampling = true;
				
				_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, audioFeed);
				_channel = _sound.play(0, 0, _transform);
			}
			else if (newData)
			{
				if (_reverse && _loops > 0) _loops++;
				_playing = _sampling = true;
			}
		}
		/**
		 * Stop playback.
		 */
		public function stop() : void
		{
			if (_sampling)
			{
				_sampling = false;
				_sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, audioFeed);
			}
			if (_channel)
			{
				_channel.soundTransform = _mute;
				_channel.stop();
				_channel = null;
			}
			_playing = false;
		}
		private function soundComplete(e : Event) : void
		{
			if (_channel)
			{
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
				_playing = false;
				_channel = null;
			}
		}
		private function audioFeed(e : SampleDataEvent) : void
		{
			if (!_playing || !_data || !_data.bytes)
			{
				_playing = _sampling = false;
				_sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, audioFeed);
				if (_channel)
				{
					_channel.soundTransform = _mute;
					_channel.stop();
					_channel = null;
				}
				return;
			}
			var bytes : ByteArray = _data._bytes;
			var feed : ByteArray = e.data;
			var end : Number = Math.min(_end, bytes.length);
			bytes.position = _p;
			var i : int = SAMPLES_PER_CALLBACK;
			var phase : Number = 0;
			var direction : int = 1 - int(reverse) * 2;
			var speed : Number = timeScale * globalTimeScale * direction;
			var bulkFeed : Boolean = timeScale * globalTimeScale == 1;
			
			while (i--)
			{
				if (!reverse && end - bytes.position < 8 || reverse && bytes.position - _start < 8)
				{
					if (pingPongPlayback) reverse = !reverse;
					bytes.position = reverse ? end : _start;
					if (_loops > 0 && _loops-- == 1)
					{
						_p = bytes.position;
						do
						{
							feed.writeDouble(0);
						}
						while (i--);
						_sampling = _playing = false;
						_sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, audioFeed);
						if (_channel) _channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
						return;
					}
				}
				
				if (!reverse && end - bytes.position > 7 || reverse && bytes.position - _start > 7)
				{
					if (_headphones)
					{
						var pos : uint = bytes.position;
						
						bytes.position = pos - (((_pan * headphonesEffect) >>> 3) << 3);
						if (bytes.position >= end - 8)
						{
							if (bytes.position >= bytes.length) bytes.position = bytes.length;
							bytes.position -= (end - _start) - 8;
						}
						else if (bytes.position < _start) bytes.position += (end - _start) - 16;
						feed.writeFloat(bytes.readFloat());
						
						bytes.position = pos + (((_pan * headphonesEffect) >>> 3) << 3);
						if (bytes.position >= end - 8)
						{
							if (bytes.position >= bytes.length) bytes.position = bytes.length;
							bytes.position -= (end - _start) - 8;
						}
						else if (bytes.position < _start) bytes.position += (end - _start) - 16;
						feed.writeFloat(bytes.readFloat());
						
						bytes.position = pos + 8;
					}
					else if(bulkFeed)
					{
						var bytesToWrite : uint = bytes.bytesAvailable;
						if (bytesToWrite >> 3 > i + 1) bytesToWrite = (i + 1) << 3;
						i -= (bytesToWrite >> 3) - 1;
						feed.writeBytes(bytes, bytes.position, bytesToWrite);
						bytes.position += bytesToWrite;
						continue;
					}
					else
					{
						feed.writeDouble(bytes.readDouble());
					}
					phase += speed;
					if (phase >= 1 || phase <= -1)
					{
						bytes.position += (int(phase) - 1) * 8;
						phase -= int(phase);
					}
					else
					{
						bytes.position -= 8 * direction;
					}
				}
				else if(bytes.length > 7)
				{
					bytes.position = 0;
					feed.writeDouble(bytes.readDouble());
				}
				else
				{
					feed.writeDouble(0);
				}
			}
			_p = bytes.position;
		}
	}

}