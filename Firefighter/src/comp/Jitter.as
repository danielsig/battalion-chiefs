package comp 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.core.Transform;
	
	/**
	 * ...
	 * @author ...
	 */
	public final class Jitter extends Component implements IExclusiveComponent 
	{
		
		public var jitter : Number = 3;
		private var _transform : Transform;
		
		public function start() : void
		{
			_transform = gameObject.transform;
		}
		
		public function update() : void
		{
			_transform.x += (Math.random() * 2 - 1) * jitter;
			_transform.y += (Math.random() * 2 - 1) * jitter;
		}
		
	}

}