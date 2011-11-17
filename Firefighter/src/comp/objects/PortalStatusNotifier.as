package comp.objects 
{
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.core.*;
	import com.battalion.*;
	import com.battalion.flashpoint.*;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;
	
	/**
	 * @author Battalion Chiefs
	 */
	public final class PortalStatusNotifier extends Component implements IExclusiveComponent 
	{
		
		private var _text : TextRenderer;
		
		public function awake() : void
		{
			_text = requireComponent(TextRenderer) as TextRenderer;
		}
		
		public function portalLocked( target : GameObject, portal : Portal, _strength : Number) : void
		{
			var message : String;
			if (_strength >= 1 && _strength < 50 )
			{
				message = "normal";
			}
			else
			{
				message = "very strong";
			}
			
			log("You got the right target");
			_text.offset = new Matrix();
			_text.offset.ty = -60;
			_text.offset.tx = -20;
			_text.text = "This is a " +  message + '\n'
				+" dooor and is locked.";
			setTimeout(clearText, 1000);
			
		}
		
		public function clearText() : void
		{
			_text.text = null;
		}
		
	}

}