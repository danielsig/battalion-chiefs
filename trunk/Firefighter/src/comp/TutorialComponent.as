package comp
{
	
	import com.battalion.flashpoint.core.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class TutorialComponent extends Component
	{
		private var _countDownToDelete : int = 5;
		
		public function awake() : void 
		{
			trace("awake: Component has been added to a GameObject");
		}
		
		public function start() : void 
		{
			trace("start: the first frame is about to be rendered.");
		}
		
		public function update() : void 
		{
			trace("update: a frame is about to be rendered.");
		}
		
		public function fixedUpdate() : void 
		{
			trace("fixedUpdate: a game logic update loop is being performed.");
			if (!_countDownToDelete--)
			{
				trace("I am about to be destroyed now, bye cruel world");
				destroy();
			}
		}
		
	}
	
}