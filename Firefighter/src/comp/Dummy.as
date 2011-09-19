package comp 
{
	
	import com.battalion.flashpoint.core.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class Dummy extends Component implements IExclusiveComponent
	{
		
		private var _dir : Number = 1;
		
		public function fixedUpdate() : void 
		{
			gameObject.transform.x += _dir * 10;
			if (gameObject.transform.x > 600)
			{
				gameObject.transform.x = -600;
			}
			else if (gameObject.transform.x < -600)
			{
				gameObject.transform.x = 600;
			}
			if (gameObject.transform.x > 0 && gameObject.transform.x < 400 && Math.random() < 0.02)
			{
				_dir = -_dir;
				gameObject.transform.scaleX = -gameObject.transform.scaleX;
			}
		}
		
	}
	
}