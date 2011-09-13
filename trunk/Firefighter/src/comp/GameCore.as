package comp
{
	
	import com.battalion.flashpoint.core.*;
	import com.greensock.TweenMax;
	import factory.BoxFactory;
	
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
			
			var box : GameObject = BoxFactory.create( { x:400, y:225, url:"assets/img/test.png" } );
			TweenMax.to(box.transform, 2, { x:50, y:50} );
		}
		
	}
	
}