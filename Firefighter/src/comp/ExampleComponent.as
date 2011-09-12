package comp 
{
	
	import com.battalion.flashpoint.core.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class ExampleComponent extends Component 
	{
		
		public function sayThis(whatToSay : String) : void 
		{
			trace("ExampleComponent: " + whatToSay);
		}
		
	}
	
}