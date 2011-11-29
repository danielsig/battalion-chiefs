package comp.objects 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.gui.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Portal extends Component implements IExclusiveComponent 
	{ 
		
		public static const OPEN_KEY : String = "e";
		public static const BREAK_KEY : String = "q"; 
		
		public var height : Number = 0;
		public var width : Number = 0;
		public var strength : Number = 1;
		public var target : Transform = null;
		public var otherPortal : Portal = null;
		public var locked : Boolean = false;
		
		private var _canPort : Boolean = true;
		private var _atPortal : Boolean = false;
		private var _bar : GameObject = null;
		
		public function lock () : void
		{
			locked = otherPortal.locked = true;
		}
		
		public function unlock () : void
		{
			locked = otherPortal.locked = false;
		}
		
		public function start() : void
		{
			requireComponent(Audio);
			Audio.load("closeDoor", "assets/sound/sounds.mp3~2383-2933~");
			Input.assignButton("openPortal", OPEN_KEY);
			Input.assignButton("breakPortal", BREAK_KEY);
		}
		
		public static function addPortal ( a : GameObject, b : GameObject, width : Number, height : Number, target : Transform, doorLocked : Boolean, strength : Number) : void
		{
			var portal1 : Portal = a.addComponent(Portal) as Portal;
			var portal2 : Portal = b.addComponent(Portal) as Portal;
			portal1.width = portal2.width = width;
			portal1.height = portal2.height = height;
			portal1.target = portal2.target = target;
			portal1.locked = portal2.locked = doorLocked;
			portal1.strength = portal2.strength = strength;
			portal1.otherPortal = portal2;
			portal2.otherPortal = portal1;
		}
		
		public function fixedUpdate () : void 
		{
			CONFIG::debug
			{
				if (!target) throw new Error("Target must be non-null.");
				if (width < 0) throw new Error ("Width must be greater then zero.");
				if (height < 0) throw new Error ("Height must be greater then zero.");
				if (!otherPortal) throw new Error ("Portal must be non-null.");
			}
			
			if (_canPort)
			{
				var top : Number = gameObject.transform.y - ( height * 0.5);
				var bottom : Number = gameObject.transform.y + ( height * 0.5);
				var left : Number = gameObject.transform.x - ( width * 0.5);
				var right : Number = gameObject.transform.x + ( width * 0.5);
				
				var x : Number = target.x;
				var y : Number = target.y;
				
				if ( (x > left && x < right) && (y > top && y < bottom))
				{
					if (_atPortal)
					{
						sendMessage("targetEnteringPortal", target.gameObject, this);
						target.sendMessage("isEnteringPortal", this);
					}
					_atPortal = true;
					sendMessage("targetAtPortal", target.gameObject, this);
					target.sendMessage("isAtPortal", this);
					if (Input.pressButton("openPortal"))
					{
						if (locked)
						{
							log("The door is locked");
							sendMessage("portalLocked", target.gameObject, this,  strength);
						}
						else
						{
							sendMessage("portalOpened", target.gameObject, this);
							target.sendMessage("openingPortal", this);
							world.cam.transform.x += otherPortal.gameObject.transform.x - target.x;
							world.cam.transform.y += otherPortal.gameObject.transform.y - target.y;
							target.x = otherPortal.gameObject.transform.x;
							target.y = otherPortal.gameObject.transform.y;
							
							otherPortal._canPort = false;
							
							sendMessage("Audio_play", "closeDoor", 1);
							
							//log(otherPortal.gameObject.name);
						}
					}
					if (locked)
					{
						if (!_bar && Input.pressButton("breakPortal"))
						{
							log("This is the right place");
							_bar = new GameObject("myBar", this.gameObject , ProgressBar);
							_bar.progressBar.value = 0;
							_bar.transform.y = -50;
						}
						else if (_bar && Input.holdButton("breakPortal"))
						{
							if (_bar.progressBar.value  < 1 )
							{
								_bar.progressBar.value +=  1 / strength;
							}
							else if (_bar.progressBar.value > 1)
							{
								log("door unlocked");
								locked = otherPortal.locked = false;
								_bar.destroy();
								_bar = null;
							}
						}
						else if (_bar && Input.releaseButton("breakPortal"))
						{
							_bar.destroy();
							_bar = null;
						}
						
					}
				}	
				else if (_atPortal)
				{
					_atPortal = false;
					sendMessage("targetLeavingPortal", target.gameObject, this);
					target.sendMessage("isLeavingPortal", this);
					
				}
				
			}
			_canPort = true;	
		}
	}
}