package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.FlashPoint;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import flash.xml.XMLNode;
	import flash.utils.Dictionary;
	/**
	 *	A BoneANimation component, AHA!
	 * @author Battalion Chiefs
	 */
	public final class BoneAnimation extends Component implements IExclusiveComponent, IPlayableComponent
	{
		private static var _animations: Object = { };
		private static var _labels: Object = { };
		
		public var localTimeScale : Number = 1;
		/**
		 * The time in milliseconds it takes for this BoneAnimation to transition between different animations.
		 */
		public var transitionTime : Number = 0;
		
		private var _pFixed : Number = 0;
		private var _p : Number = 0;//playhead
		private var _length : uint;
		private var _framesPerSecond : Number = 30;
		private var _animation : Object;// GoFrames
		private var _bones : Object = { };// Transforms
		private var _boneAnimName : String = null;
		private var _playing : Boolean;
		private var _loops : uint = 0;
		private var _playback : Number = 1;
		private var _pingPongPlayback : Boolean = false;
		private var _multiplier : Number = 1;
		private var _multiplierChangeAmount : Number = 0;
		private var _messages : Dictionary = null;
		private var _prevFrame : Number = 0;
		
		/** @private **/
		public function onDestroy() : Boolean
		{
			_animation = null;
			for (var boneName : String in _bones)
			{
				delete _bones[boneName];
			}
			_bones = null;
			_boneAnimName = null;
			return false;
		}
		
		/**
		 * This comes in handy when you want something to happen at a specific frame.
		 * <p>
		 * A BoneAnimation component playing an animation named <code>boneAnimName</code>
		 * will send a message named <code>label</code> with paramerts <code>...params</code>
		 * when it reaches a frame index <code>frame</code>.
		 * </p>
		 * @see Animation.addLabel()
		 * @param	boneAnimName
		 * @param	label
		 * @param	frame
		 * @param	...params
		 */
		public static function addLabel(boneAnimName : String, label : String, frame : Number, ...params) : void
		{
			var labels : Dictionary = _labels[boneAnimName];
			CONFIG::debug
			{
				if (!_labels.hasOwnProperty(boneAnimName))
				{
					throw new Error("Either the boneAnimName you specified is not correct or you're trying to assign labels to a bone animation before defining it.");
				}
				if (!(frame is int || frame is uint || frame is Number))
				{
					throw new Error(frame + " is not a valid label index.");
				}
				if (frame <= -labels.length || frame >= labels.length)
				{
					throw new Error("labels index " + frame + " is out of range [" + -labels.length + "-" + labels.length + "] of " + boneAnimName + ".");
				}
				if (!label || !(label is String))
				{
					throw new Error(label + " is not a valid label name.");
				}
			}
			_labels[boneAnimName][frame < 0 ? labels.length + frame - 1 : frame] = [label].concat(params);
		}
		
		/**boneAnimName = Tekur inn nafn á animation
		*frameInterval = hversu fljótt animationið fer á milli ramma
		*definition = dynamic object fyrir animationið
		*/
		public static function define(boneAnimName: String, framesPerSecond: Number, definition: Object) : void
		{
			CONFIG::debug
			{
				var length : uint = 0;
				if (_animations[boneAnimName])
				{
					trace("BoneAnimation: Trying to create object that already exists")
				}
			}
			var definedAnimation : Object = { };
			for (var gameObjectName : String in definition)
			{
				var values : Array = definition[gameObjectName];//[0, 90, 180}
				var prop : String = gameObjectName.charAt(gameObjectName.length - 1);//A
				gameObjectName = gameObjectName.slice(0, gameObjectName.length - 1);//t
				
				if(!definedAnimation[gameObjectName]) definedAnimation[gameObjectName] = new GoFrame(values.length);
				
				var frames : GoFrame = definedAnimation[gameObjectName];
				
				var c : uint = 0;
				var value : Number;
				
				CONFIG::debug
				{
					if(!length) length = values.length;
					if (values.length != length)
					{
						throw new Error("Please do not have a varying number of frames. "
						+ "In " + boneAnimName + " the length of " + gameObjectName + prop + " is " + values.length + ", was excpeting a length of " + length + ".");
					}
				}
				
				if (prop == 'A')
				{	
					for each(value in values)
					{
						frames.angles[c++] = value;
					}
				}
				else if (prop == 'X')
				{	
					for each(value in values)
					{
						frames.xPos[c++] = value;
					}
				}
				else if (prop == 'Y')
				{	
					for each(value in values)
					{
						frames.yPos[c++] = value;
					}
				}
				
			}
			
			definedAnimation.framesPerSecond = framesPerSecond;
			definedAnimation.length = values.length;
			
			_animations[boneAnimName] = definedAnimation;
			_labels[boneAnimName] = new Dictionary();
		}
		
		/**
		 * Determines if playback should reverse every time it reaches an end.
		 */
		public function get pingPongPlayback() : Boolean
		{
			return _pingPongPlayback;
		}
		public function set pingPongPlayback(value : Boolean) : void
		{
			_pingPongPlayback = value;
		}
		
		/**
		 * The direction of the animation relative to the original direction of the animation.
		 * A value of:
		 * <ul>
		 * <li>
		 * <code>true</code> means that the animation is a reversed version of the original animation.
		 * </li>
		 * <li>
		 * <code>false</code> means that the animation is the same as the original animation.
		 * </li>
		 * </ul>
		 */
		public function get reversed() : Boolean
		{
			return _playback < 0;
		}
		public function set reversed(value : Boolean) : void
		{
			_playback = 1 - (int(value) << 1);
		}
		
		public function get playing() : Boolean
		{
			return _playing;
		}
		public function set playing(value : Boolean) : void
		{
			if(_boneAnimName) _playing = value;
		}
		
		public function get playhead() : Number
		{
			return _p * _length;
		}
		public function set playhead(value : Number) : void
		{
			value %= _length;
			_p = value < 0 ? _length + value / _length : value / _length;
		}
		
		
		/**
		 * current animation's name. Set this to change the current animation.
		 * @see #play()
		 */
		public function get currentName() : String
		{
			return _boneAnimName;
		}
		
		public function set currentName(value : String) : void
		{
			CONFIG::debug
			{
				if (!_animations.hasOwnProperty(value)) throw new Error("The animation you are trying to play has not been defined.");
			}
			_boneAnimName = value;
			_animation = _animations[value];
			_length = _animation.length;
			_framesPerSecond = _animation.framesPerSecond;
			_p = _pFixed = 0;
			_multiplierChangeAmount = FlashPoint.fixedInterval / transitionTime;
			_multiplier = 0;
			_playback = 1;
			_messages = _labels[value];
			
			for (var boneName : String in _animation)
			{
				if (boneName != "length" && boneName != "framesPerSecond" && !_bones[boneName]) _bones[boneName] = gameObject.findGameObjectDownwards(boneName).transform;
			}
			for (boneName in _bones)
			{
				if (!_animation[boneName]) delete _bones[boneName];
			}
		}
		
		/**
		 * Resume playback/select an animation to play.
		 * <p>
<pre>When resuming playback, leave the <code>boneAnimName</code> parameter blank.
When selecting another animation, set the <code>boneAnimName</code> to the desired animation. The animation will play starting from the first frame of that animation.</pre>
		 * </p>
		 * @see #currentAnimation
		 * @param animationName, the name of the animation to play
		 * @param loops, the number of loops to perform, 0 means it will loop forever, 1 means it will only play once, etc.
		 */
		public function play(boneAnimName : String = null, loops : uint = 0) : void
		{
			if (boneAnimName && boneAnimName != _boneAnimName) currentName = boneAnimName;
			_playing = true;
			_loops = loops;
		}
		
		public function stop(): void
		{
			_playing = false;
			_p = 0;
		}
		public function pause(): void
		{
			_playing = false;
		}
		/**
		 * Sets the current animation to the given animation (if not omitted)
		 * and then puts the playhead at the given frame.
		 * @see #currentAnimation
		 * @see #pause
		 * @param frame, the frame number to put the playhead at
		 * @param boneAnimName, the name of the new animation to set as the current animatuon (optional)
		 */
		public function gotoAndPause(frame : Number, boneAnimName : String = null): void
		{
			CONFIG::release
			{
				if (boneAnimName && boneAnimName != _boneAnimName) currentName = boneAnimName;
			}
			CONFIG::debug
			{
				if (boneAnimName)
				{
					if(boneAnimName != _boneAnimName) currentName = boneAnimName;
				}
				else if (!_boneAnimName) throw new Error("You must define a bone animation before calling this method!");
				if (frame <= -_length || frame >= _length) throw new Error("Can not set the playhead to " + frame + " for it is out of range [" + -_length + " - " + _length + "]");
			}
			_p = _pFixed = frame < 0 ? _length + frame / _length : frame / _length;
			_playing = false;
		}
		/**
		 * Sets the current animation to the given animation (if not omitted)
		 * and then start playback beginning at the given frame.
		 * @see #currentAnimation
		 * @see #play
		 * @param Number, frame the frame number to start playing from
		 * @param String, boneAnimName the name of the new animation to play (optional)
		 */
		public function gotoAndPlay(frame : Number, boneAnimName : String = null): void
		{
			CONFIG::release
			{
				if (boneAnimName && boneAnimName != _boneAnimName) currentName = boneAnimName;
			}
			CONFIG::debug
			{
				if (boneAnimName)
				{
					if(boneAnimName != _boneAnimName) currentName = boneAnimName;
				}
				else if (!_boneAnimName) throw new Error("You must define a bone animation before calling this method!");
			}
			frame %= _length;
			_p = _pFixed = frame < 0 ? _length + frame / _length : frame / _length;
			_playing = true;
		}
		
		/** @private **/
		public function update() : void
		{
			if (_playing)
			{
				// UPDATE PLAYHEAD
				
				var framesPerFixedFrame : Number = (FlashPoint.fixedInterval * 0.001) * _framesPerSecond;
				var frameLength : Number = localTimeScale / _length;
				var step : Number = frameLength * (FlashPoint.frameInterpolationRatio || 1) * framesPerFixedFrame * _playback;
				if (_loops == 1) _p = _pFixed + step;
					
				if (_p >= 1 || _p < 0)
				{
					if (_loops > 0 && _loops-- == 1)
					{
						_playing = false;
						return;
					}
					if (_pingPongPlayback) _playback = -_playback;
					else _p = _pFixed = (_p < 0 ? 1 : 0);
				}
				
				if (_loops != 1) _p = _pFixed + frameLength * (FlashPoint.frameInterpolationRatio || 1) * framesPerFixedFrame * _playback;
				
				if (_p > 1) _p %= 1;
				else if (_p < 0) _p = (_p % 1) + 1;
				
				if (!FlashPoint.frameInterpolationRatio)
				{
					_pFixed = _p;
				}
				
				
				// UPDATE BONES
				
				var currentFrame : Number = _p * (_length - 1);
				var floorFrame : int = currentFrame;//will be rounded down
				var ceilFrame : int = floorFrame + 1;
				if (ceilFrame >= _length) ceilFrame--;
				
				var ceilRatio : Number = currentFrame - floorFrame;
				var floorRatio : Number = 1 - ceilRatio;
				
				if (_multiplierChangeAmount)
				{
					_multiplier += _multiplierChangeAmount * FlashPoint.deltaRatio;
					if (_multiplier > 1)
					{
						_multiplier = 1;
						_multiplierChangeAmount = 0;
					}
				}
				for (var boneName : String in _bones)
				{
					_bones[boneName].x +=  (_animation[boneName].xPos[floorFrame] * floorRatio
										+ _animation[boneName].xPos[ceilFrame]  * ceilRatio - _bones[boneName].x) * _multiplier;
					_bones[boneName].y +=  (_animation[boneName].yPos[floorFrame] * floorRatio
										+ _animation[boneName].yPos[ceilFrame]  * ceilRatio - _bones[boneName].y) * _multiplier;
					var a1 : Number = _animation[boneName].angles[floorFrame];
					var a2 : Number = _animation[boneName].angles[ceilFrame];
					if (a2 - a1 > 180) a1 += 360;
					if (a2 - a1 < -180) a1 -= 360;
					_bones[boneName].rotation += (a1 * floorRatio + a2  * ceilRatio - _bones[boneName].rotation) * _multiplier;
				}
				if (_playback > 0)
				{
					if (currentFrame < _prevFrame) _prevFrame = 0;
					for (var fr : Object in _messages)
					{
						if (currentFrame >= fr && _prevFrame < fr)
						{
							sendMessage.apply(this, _messages[fr]);
						}
					}
				}
				else if(_playback < 0)
				{
					if (_prevFrame < currentFrame) _prevFrame = _length - 1;
					for (fr in _messages)
					{
						if (currentFrame <= fr && _prevFrame > fr)
						{
							sendMessage.apply(this, _messages[fr]);
						}
					}
				}
				_prevFrame = currentFrame;
			}
		}
		public function reverse() : void
		{
			_playback = -_playback;
		}
	}

}