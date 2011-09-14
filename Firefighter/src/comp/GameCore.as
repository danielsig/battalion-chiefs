package comp
{
	import flash.display.PixelSnapping;
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
			
			var box2 : GameObject = BoxFactory.create( { x:400, y:100, name:"box2", url:"assets/img/test.png" } );
			var box3 : GameObject = BoxFactory.create( { x:600, y:100, name:"box3", url:"assets/img/test.png" } );
			var box1 : GameObject = BoxFactory.create( { x:200, y:100, name:"box1", url:"assets/img/test.png", children:[box2, box3]} );

			//box1.transform.rotation = 90;
			/*
			world.box1.transform.log();
			world.box2.transform.log();
			world.box3.transform.log();
			
			TweenMax.to(box1.transform, 2, { scaleX:1, rotation:-90 } );
			TweenMax.to(box2.transform, 2, { scaleX:2 } );
			TweenMax.to(box3.transform, 2, { scaleX:2, rotation: -90, onComplete:complete } );
			*/
			world.cam.transform.x = 400;
			world.cam.transform.y = 360;
			world.cam.transform.scale = 2;
		}
		public function complete() : void
		{
			/*
			world.box1.transform.log();
			world.box2.transform.log();
			world.box3.transform.log();
			*/
		}
		
	}
	
}