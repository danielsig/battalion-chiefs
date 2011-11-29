package comp.debug 
{
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.flashpoint.core.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class MouseLocation extends Component implements IExclusiveComponent 
	{
		
		public static function create() : void
		{
			new GameObject("mouseLocator", MouseLocation, FollowMouse, TextRenderer);
		}
		
		private var _text : TextRenderer = null;
		
		public function awake() : void
		{
			requireComponent(FollowMouse);
			_text = requireComponent(TextRenderer) as TextRenderer;
			_text.width = 128;
			_text.setOffset(70, -8);
			_text.font = "arial";
			_text.color = 0x440044;
			_text.bold = true;
		}
		public function update() : void
		{
			_text.text = "(" + gameObject.transform.gx.toPrecision(5) + ", " + gameObject.transform.gy.toPrecision(5) + ")"
		}
		
	}

}