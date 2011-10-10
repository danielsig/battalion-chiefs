package comp 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Portal extends Component implements IExclusiveComponent 
	{ 
		public var height : Number;
		public var width : Number;
		public var target : Transform;
		public var  otherPortal : Portal;
		private var _canPort : Boolean = true;
		
		public function start() : void
		{
			Input.assignButton("openPortal", "e");
		}
		
		public static function addPortal ( a : GameObject, b : GameObject, width : Number, height : Number, target : Transform) : void
		{
			var portal1 : Portal = a.addComponent(Portal) as Portal;
			var portal2 : Portal = b.addComponent(Portal) as Portal;
			portal1.width = portal2.width = width;
			portal1.height = portal2.height = height;
			portal1.target = portal2.target = target;
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
					sendMessage("targetAtPortal", target.gameObject, this);
					target.sendMessage("isAtPortal", this);
					if (Input.pressButton("openPortal"))
					{
						sendMessage("portalOpened", target.gameObject, this);
						target.sendMessage("openingPortal", this);
						world.cam.transform.x += otherPortal.gameObject.transform.x - target.x;
						world.cam.transform.y += otherPortal.gameObject.transform.y - target.y;
						target.x = otherPortal.gameObject.transform.x;
						target.y = otherPortal.gameObject.transform.y;
						otherPortal._canPort = false;
						
						log(otherPortal.gameObject.name);
					}
				}
			}
			_canPort = true;	
		}
	}
}