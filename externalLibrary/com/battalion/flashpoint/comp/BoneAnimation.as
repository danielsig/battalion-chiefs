package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.FlashPoint;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import flash.xml.XMLNode;
	/**
	 *	A BoneANimation component, AHA!
	 * @author Battalion Chiefs
	 */
	public final class BoneAnimation extends Component implements IExclusiveComponent
	{
		private static var _animations: Object = { };
		
		public var localTimeScale : Number = 1;
		
		private var _pFixed : Number = 0;
		private var _p : Number = 0;//playhead
		private var _length : uint;
		private var _framesPerSecond : Number = 30;
		private var _animation : Object;// GoFrames
		private var _bones : Object = { };// Transforms
		private var _boneAnimName : String = null;
		private var _playing : Boolean;
		
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
		}
		
		/**
		 * current animation's name. Set this to change the current animation.
		 * @see #play()
		 */
		public function get currentAnimation() : String
		{
			return _boneAnimName;
		}
		
		public function set currentAnimation(value : String) : void
		{
			CONFIG::debug
			{
				if (!_animations.hasOwnProperty(value)) throw new Error("The animation you are trying to play has not been defined.");
			}
			_animation = _animations[value];
			_length = _animation.length;
			_framesPerSecond = _animation.framesPerSecond;
			_p = _pFixed = 0;
			
			for (var boneName : String in _animation)
			{
				if (boneName != "length" && boneName != "framesPerSecond") _bones[boneName] = gameObject.findGameObjectDownwards(boneName).transform;
			}
			_boneAnimName = value;
		}
		
		/**
		 * Resume playback/select an animation to play.
		 * <p>
<pre>When resuming playback, leave the <code>boneAnimName</code> parameter blank.
When selecting another animation, set the <code>boneAnimName</code> to the desired animation. The animation will play starting from the first frame of that animation.</pre>
		 * </p>
		 * @see #currentAnimation
		 */
		public function play(boneAnimName : String = null) : void
		{
			if (boneAnimName != _boneAnimName) currentAnimation = boneAnimName;
			_playing = true;
		}
		
		public function stop(): void
		{
			_playing = false;
		}

		public function update() : void
		{
			if (_playing)
			{
				// UPDATE PLAYHEAD
				if (_p >= 1) _p = _pFixed = 0;
				var framesPerFixedFrame : Number = (FlashPoint.fixedInterval * 0.001) * _framesPerSecond;
				var frameLength : Number = localTimeScale / _length;
				_p = _pFixed + frameLength * (FlashPoint.frameInterpolationRatio || 1) * framesPerFixedFrame;
				
				if (_p > 1) _p %= 1;
				else if (_p < 0) _p = 0;
				
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
				
				for (var boneName : String in _bones)
				{
					_bones[boneName].x =  _animation[boneName].xPos[floorFrame] * floorRatio
										+ _animation[boneName].xPos[ceilFrame]  * ceilRatio;
					_bones[boneName].y =  _animation[boneName].yPos[floorFrame] * floorRatio
										+ _animation[boneName].yPos[ceilFrame]  * ceilRatio;
					var a1 : Number = _animation[boneName].angles[floorFrame];
					var a2 : Number = _animation[boneName].angles[ceilFrame];
					if (a2 - a1 > 180) a1 += 360;
					if (a2 - a1 < -180) a1 -= 360;
					_bones[boneName].rotation = a1 * floorRatio
											  + a2  * ceilRatio;
				}
			}
		}
		
	}

}