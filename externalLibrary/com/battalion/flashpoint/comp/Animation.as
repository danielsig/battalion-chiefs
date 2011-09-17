package com.battalion.flashpoint.comp 
{
	
	import com.battalion.flashpoint.core.*;
	import com.danielsig.BitmapLoader;
	import com.danielsig.StringUtilPro;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * Animation component. Iterates through bitmaps, one iteration per frame.
	 * Use the static method <a href="../comp/Animation.html#load()"><code>load()</code></a> to load an animation and assign a name to it.
	 * Use the <a href="../comp/Animation.html#play()"><code>play()</code></a> method to play an animation.
	 * <p>
	 * <strong>Requires:</strong><ul><li><a href="Renderer.html">Renderer</a></li></ul>
	 * </p>
	 * @author Battalion Chiefs
	 */
	public final class Animation extends Component implements IExclusiveComponent
	{
		private static var _animations : Object = { };
		private static var _animationLabels : Object = { };
		
		/**
		 * This comes in handy when you want something to happen at a specific frame.
		 * <p>
		 * An animation component playing an animation named <code>animationName</code>
		 * will send a message named <code>label</code> with paramerts <code>...params</code>
		 * when it reaches a frame index <code>frame</code>.
		 * </p>
		 * Use the <a href="../comp/Animation.html#load()"><code>load()</code></a> or the <a href="../comp/Animation.html#loadAndPlay()"><code>loadAndPlay()</code></a> methods to start loading an animation before adding labels.
		 * @example An example of how to destroy a GameObject after it has played an animation.<listing version="3.0">
var myObj : GameObject = new GameObject(Animation, Destroyer);
Animation.load("myAnimation", "images/mySpriteSheet.png~0-4~");
Animation.addLabel("myAnimation", "destroyer", -1);
myObj.play("myAnimation");
	</listing>
	@example An example of how to play a sound at the 2nd frame.<listing version="3.0">
var myObj : GameObject = new GameObject(Animation, Audio);
Audio.load("mySound", "audio/mySound.mp3");
Animation.load("myAnimation", "images/mySpriteSheet.png~0-4~");
Animation.addLabel("myAnimation", "playAudio", 2, "mySound");
myObj.animation.play("myAnimation");
	</listing>
		 * @param	animationName
		 * @param	label
		 * @param	frame
		 * @param	...params
		 */
		public static function addLabel(animationName : String, label : String, frame : int, ...params) : void
		{
			CONFIG::debug
			{
				if (!_animationLabels.hasOwnProperty(animationName))
				{
					throw new Error("Either the animationName you specified is not correct or you're trying to assign labels to an animation before starting loading it.");
				}
				var labels : Vector.<Array> = _animationLabels[animationName];
				if (!(frame is int || frame is uint || frame is Number))
				{
					throw new Error(frame + " is not a valid label index.");
				}
				if (frame <= -labels.length || frame >= labels.length)
				{
					throw new Error("labels index " + frame + " is out of range [" + -labels.length + "-" + labels.length + "] of " + animationName + ".");
				}
				if (!label || !(label is String))
				{
					throw new Error(label + " is not a valid label name.");
				}
			}
			_animationLabels[animationName][frame < 0 ? labels.length + frame - 1 : frame] = [label].concat(params);
		}
		/**
		 * Loads an animation from URLs of bitmap images that will be used as frames.
		 * <p>
		 * Every frame has only one bitmap.
		 * Can be both individual image urls and/or spritesheet urls. Can also read spritesheet ranges.
		 * </p>
		 * <strong>See also</strong>
<pre>   <a href="../../../danielsig/BitmapLoader.html">BitmapLoader</a>
   <a href="../../../danielsig/SpriteSheet.html">SpriteSheet</a></pre>
		 * @example A spritesheet url is written in the folowing format: <listing version="3.0">"imageURL.imageFormat~spriteSheetIndex~alternativeURL"</listing>
		 * @example To get the second bitmap of a sritesheet at "imgages/mySpriteSheet.png" you should write:<listing version="3.0">"images/mySpriteSheet.png~2~"</listing>
		 * @example A spritesheet url with a range is written in the folowing format: <listing version="3.0">"imageURL.imageFormat~fromIndex-toIndex~alternativeURL"</listing>
		 * @example To get the bitmaps of index 0, 1, 2, 3 and 4 of a sritesheet at "imgages/mySpriteSheet.png" you should write:<listing version="3.0">"images/mySpriteSheet.png~0-4~"</listing>
		 * 
		 * @example <strong>Hint:</strong> to get the images in a reverse order (handy for reversed animation) just swap the indexes.<listing version="3.0">"images/mySpriteSheet.png~4-0~"</listing>
		 * @param	animationName the name of the animation. This will act as a reference to the loaded animation.
		 * @param	...frameURLs a list of urls to load.
		 */
		public static function load(animationName : String, ...frameURLs) : void
		{
			var index : int = 0;
			var urls : Vector.<String> = new Vector.<String>(frameURLs.length);
			var frames : Vector.<BitmapData> = new Vector.<BitmapData>();
			for each(var url : String in frameURLs)
			{
				var tildeIndex2 : int = url.lastIndexOf("~");
				var tildeIndex1 : int = url.lastIndexOf("~", tildeIndex2 - 1);
				if (tildeIndex1 > -1)
				{
					tildeIndex1++;
					var spriteIndexes : String = url.slice(tildeIndex1, tildeIndex2);
					var delimIndex : int = spriteIndexes.indexOf("-");
					var start : int = int(spriteIndexes.slice(0, delimIndex));
					var end : int = int(spriteIndexes.slice(delimIndex + 1));
					var rawURL : String = url.slice(0, tildeIndex1);
					if (end >= start)//e.g. 0-9, 2-2, 6-11
					{
						urls.length += end - start;//adds one less to the length than number of sprites added.
						while (start <= end)
						{
							urls[index++] = rawURL + start++ + "~";
						}
					}
					else//e.g. 9-0, 11-6
					{
						urls.length += start - end;
						while (start >= end)
						{
							urls[index++] = rawURL + (start--) + "~";
						}
					}
				}
				else
				{
					urls[index++] = url;
				}
			}
			_animations[animationName] = frames;
			_animationLabels[animationName] = new Vector.<Array>(index);
			var loader : BitmapLoader = new BitmapLoader(urls, frames, CONFIG::debug, null, false);
			loader.start();
		}
		/**
		 * Traces out currently loaded/loading animations and their labels.
		 */
		public static function listAnimations() : void
		{
			var sple : StringUtilPro;
			trace("animations\n{");
			for (var animationName : String in _animations)
			{
				trace(StringUtilPro.toMinLength("\t" + animationName + "$", 50) + "labels: [" + _animationLabels[animationName].join(",") + "]");
			}
			trace("}");
		}
		
		/** @private **/
		internal var _p : int = 0;//playHead
		/** @private **/
		internal var _frames : Vector.<BitmapData>;
		/** @private **/
		internal var _length : int = 0;//just for convenience
		/** @private **/
		internal var _messages : Vector.<Array>;
		/** @private **/
		internal var _playing : Boolean = false;
		/** @private **/
		internal var _animationName : String = null;
		private var _cloned : Boolean = false;//see the reverse() method
		private var _renderer : Renderer;//just for convenience
		
		/**
		 * Basically the same thing as the static counterpart <a href="../comp/Animation.html#load()"><code>load()</code></a> except that this method does not require a name.
		 * The animation will have the same name as the GameObject of this animation component + "Animation". Basicly an animation component in a GameObject named "player" will name the animation "playerAnimation".
		 * @param	...frameURLs a list of urls to load.
		 */
		public function loadAndPlay(...frameURLs) : void
		{
			var name : String = gameObject.name + "Animation";
			load.apply(this, [name].concat(frameURLs));
			play(name);
		}
		
		/** @private **/
		public function awake() : void
		{
			_renderer = requireComponent(Renderer) as Renderer;
		}
		
		/**
		 * The current playhead position in the current animation, can be used for jumping to a specific frame.
		 * Setting this to a negative number will make it jump to a frame counting backwards from the end of the animation.
		 */
		public function get currentFrame() : int
		{
			return _p;
		}
		public function set currentFrame(frame : int) : void
		{
			CONFIG::debug
			{
				if (frame <= -_length || frame >= _length) throw new Error("frame " + frame + " is out of range [" + -_length + "-" + _length + "]");
			}
			_p = frame < 0 ? _length + frame - 1 : frame;
		}
		/**
		 * Number of frames in the current animation.
		 */
		public function get numFrames() : int
		{
			return _length;
		}
		/**
		 * current animation's name. Set this to change the current animation.
		 * @see #play()
		 */
		public function get currentAnimation() : String
		{
			return _animationName;
		}
		public function set currentAnimation(value : String) : void
		{
			CONFIG::debug
			{
				if (!_animations.hasOwnProperty(value)) throw new Error("The animation you are trying to play has not been loaded.");
			}
			_frames = _animations[value];
			_messages = _animationLabels[value];
			_length = _frames.length;
			_p = 0;
		}
		
		/** @private **/
		public function fixedUpdate() : void
		{
			if (_playing)
			{
				if (++_p >= _length) _p = 0;
				_renderer.bitmapData = _frames[_p];
				_renderer.updateBitmap = _renderer.bitmapData != null;
				if (_messages[_p])
				{
					sendMessage.apply(this, _messages[_p]);
				}
			}
		}
		
		/**
		 * Stop playback.
		 */
		public function stop() : void
		{
			_playing = false;
		}
		/**
		 * jumps to a specific frame and stops there.
		 * Setting this to a negative number will make it jump to a frame counting backwards from the end of the animation.
		 */
		public function gotoAndStop(frame : int) : void
		{
			CONFIG::debug
			{
				if (frame <= -_length || frame > _length) throw new Error("frame " + frame + " is out of range [" + -_length + "-" + _length + "]");
			}
			_p = frame < 0 ? _length + frame - 1 : frame;
			_playing = false;
		}
		/**
		 * jumps to a specific frame and plays from there.
		 * Setting this to a negative number will make it jump to a frame counting backwards from the end of the animation.
		 */
		public function gotoAndPlay(frame : int) : void
		{
			CONFIG::debug
			{
				if (frame <= -_length || frame > _length) throw new Error("frame " + frame + " is out of range [" + -_length + "-" + _length + "]");
			}
			_p = frame < 0 ? _length + frame - 1 : frame;
			_playing = true;
		}
		/**
		 * Resume playback/select an animation to play.
		 * <p>
<pre>When resuming playback, leave the <code>animationName</code> parameter blank.
When selecting another animation, set the <code>animationName</code> to the desired animation. The animation will play starting from the first frame of that animation.</pre>
		 * </p>
		 * @see #currentAnimation
		 */
		public function play(animationName : String = null) : void
		{
			if (animationName)
			{
				CONFIG::debug
				{
					if (!_animations.hasOwnProperty(animationName)) throw new Error("The animation you are trying to play has not been loaded.");
				}
				_frames = _animations[animationName];
				_messages = _animationLabels[animationName];
				_length = _frames.length;
				_p = 0;
			}
			_playing = true;
		}
		/**
		 * Basicly reverses the frames of the animation of this animation component. This does not affect other animation components playing the same animation.
		 * <p>
		 * The playhead will remain on the same frame as it was on before reversal. Meaning if the playhead is on the first frame before reversal, it's on the last frame after reversal etc.
		 * </p>
		 */
		public function reverse() : void
		{
			_frames = (_cloned ? _frames : _frames.concat()).reverse();
			_p = _length + _p - 1;
		}
	}
	
}