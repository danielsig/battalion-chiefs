package comp
{
	
	import com.battalion.flashpoint.core.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class GameCore extends Component implements IExclusiveComponent
	{
		
		public function start() : void 
		{
			addConcise(ExampleConcise, "sayHello");
			sendMessage("sayHello");//will be recieved, but the concise component will destroy itself afterwards.
			sendMessage("sayHello");//will NOT be recieved, because concise component has already destroyed itself.
			
			addComponent(ExampleComponent);
			sendMessage("sayThis", "YAHOO!");
			sendMessage("sayThis", "YAHOO!");//normal components do not destroy themselves like concise components.
			gameObject.exampleComponent.destroy();
			sendMessage("sayThis", "YAHOO!");//no reciever, ExampleComponent has been destroyed.
			
			addComponent(TutorialComponent);
		}
		
	}
	
}