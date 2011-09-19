package com.battalion.audio 
{
	import flash.media.ID3Info;
	import flash.utils.ByteArray;
	/**
	 * An AudioData object holds information about an audio file.
	 * This class was made to be used alongside the AudioLoader
	 * and AudioPlayer classes. The relationship between this class,
	 * the AudioLoader class and the AudioPlayer class was designed
	 * to be similar to the relationship between the Loader class,
	 * BitmapData class and the Bitmap class.
	 * 
	 * @see AudioLoader
	 * @see AudioPlayer
	 * 
	 * @author Battalion Chiefs
	 */
	public final class AudioData 
	{
		
		/** @private **/
		internal var _bytes : ByteArray;
		/** @private **/
		internal var _id3 : ID3Info;
		/** @private **/
		internal var _start : Number;
		/** @private **/
		internal var _end : Number;
		/** @private **/
		internal var _length : Number;
		
		/**
		 * The length of the final Audio in milliseconds.
		 */
		public function get length() : Number
		{
			return _length;
		}
		/**
		 * The length of the currently loaded Audio in milliseconds.
		 */
		public function get loadedLength() : Number
		{
			return _bytes.length * 0.00283446712;
			//(1 / 44.1) / 8 = 0.00283446712
		}
		
		/**
		 * @see flash.util.ID3Info
		 */
		public function get id3() : ID3Info
		{
			return _id3;
		}
		/**
		 * Do not use the constructor unless you want a partition of another AudioData object.
		 * It's useless to make copies, they aren't actually copies.
		 * @param	original
		 * @param	start
		 * @param	end
		 */
		public function AudioData(original : AudioData, start : Number = 0, end : Number = Number.MAX_VALUE)
		{
			if (original)
			{
				_bytes = original._bytes;
				_id3 = original._id3;
				_start = original._start + start;
				_end = original._start + end;
			}
			else
			{
				_start = start;
				_end = end;
			}
		}
		/**
		 * The audio samples in a ByteArray. Use this property in order to generate your own audio.
		 * The audio data is always exposed as 44.1kHz Stereo. Each sample is composed of two 32-bit floating-point values,
		 * representing the left and right channels, respectively. They can be converted to <code>Numbers</code> using <code>ByteArray.readFloat()</code>.
		 */
		public function get bytes() : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			var pos : uint = _bytes.position;
			_bytes.position = 0;
			bytes.writeBytes(_bytes);
			_bytes.position = pos;
			return bytes;
		}
		public function set bytes(bytes : ByteArray) : void
		{
			_bytes.clear();
			var pos : uint = bytes.position;
			bytes.position = 0;
			_bytes.writeBytes(bytes);
			bytes.position = pos;
		}
		
		/**
		 * Call this method when you're done using this AudioData object.
		 */
		public function dispose() : void
		{
			_bytes.clear();
			_bytes = null;
			_id3 = null;
		}
		
	}

}