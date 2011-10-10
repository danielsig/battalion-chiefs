package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
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
		
		private var _p : Number = 0;//playhead
		private var _length : Number;
		private var _animation : Object;
		private var _playing : Boolean;
		private var _boneAnimName : String = null;
		private var _bones : Object = { };
		
		/**boneAnimName = Tekur inn nafn á animation
		*frameInterval = hversu fljótt animationið fer á milli ramma
		*definition = dynamic object fyrir animationið
		*/
		public static function define(boneAnimName: String, frameInterval: Number, definition: Object) : void
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
				
				if(!definition[gameObjectName]) definedAnimation[gameObjectName] = new GoFrame(values.length);
				
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
			
			definedAnimation.frameInterval = frameInterval;
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
			_p = 0;
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
			if (boneAnimName)
			{
				CONFIG::debug
				{
					if (!_animations.hasOwnProperty(boneAnimName)) throw new Error("The bone animation you are trying to play has not been loaded.");
				}
				if (++_p >= _length) _p = 0;
				
				_animation = _animations[boneAnimName];
				_length = _animation[boneAnimName].
				_p = 0;
				
				for (var boneName : String in _animation)
				{
					_bones[boneName] = gameObject.findGameObjectDownwards(boneName);
				}
				
				
			}
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
				if (++_p >= _length) _p = 0;
				
				
				
			}
		}
		
	}

}