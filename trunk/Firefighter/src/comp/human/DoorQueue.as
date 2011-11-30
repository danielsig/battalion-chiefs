package comp.human 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import comp.objects.Portal;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class DoorQueue extends Component 
	{
		
		internal var _civilian : CivilianController = null;
		
		public function openingPortal(portal : Portal) : void
		{
			if (_civilian) _civilian._doorQueue.push(portal);
		}
		
	}

}