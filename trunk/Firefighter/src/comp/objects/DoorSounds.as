package comp.objects 
{
	import com.battalion.flashpoint.comp.Audio;
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.GameObject;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class DoorSounds extends Component implements IExclusiveComponent 
	{
		private static var _init : Boolean = init();
		
		private static function init() : Boolean
		{
			Audio.load("closeDoor", "assets/sound/sounds.mp3~2383-2933~");
			return true;
		}
				
		public var direction : uint = 0;
		
		public function start() : void
		{
			var offset : Number = 0;
			switch(direction)
			{
				case 3:
					offset = 0.5;
					break;
				case 2:
					offset = -0.5;
					break;
				case 1:
				default:
					offset = 0;
			}
			(requireComponent(Audio) as Audio).panOffset = offset;
		}
		
		public function portalClosed(player : GameObject, portal : Portal) : void
		{
			sendMessage("Audio_play", "closeDoor", 1);
		}
		public function portalOpened(player : GameObject, portal : Portal) : void
		{
			sendMessage("Audio_stop");
		}
		
	}

}