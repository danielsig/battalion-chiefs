package comp 
{
	
	import com.battalion.flashpoint.comp.Camera;
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.flashpoint.comp.Animation;
	import com.battalion.Input;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class DummyController extends Component implements IExclusiveComponent
	{
		
		public var speed : Number = 50;
		public var backSpeed : Number = 30;
		public var runSpeed : Number = 100;
		public var jumpSpeed : Number = 100;
		
		public function awake() : void 
		{
			requireComponent(TimeMachine);
			requireComponent(Zoomer);
			(world.cam.addComponent(Follow) as Follow).follow(gameObject, 0.08);
			//gameObject.zoomer.zoom(10);
			
			Input.assignDirectional("samusDirection", "d", "a", Keyboard.RIGHT, Keyboard.LEFT);
			Input.assignButton("shift", Keyboard.SHIFT);
			Input.assignButton("jump", Keyboard.SPACE);
		}
			
		public function fixedUpdate() : void 
		{
			var thisPos : Point = (gameObject.transform as Transform).globalPosition;
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			var isMouseOnTheLeft : Boolean = mousePos.x < thisPos.x;
			
			//var points : Vector.<ContactPoint> = gameObject.rigidbody.touchingInDirection(new Point(0, 1), 0.1);
			//if (points)
			{
				if (Input.directional("samusDirection") > 0)
				{
					gameObject.rigidbody.addForceX((isMouseOnTheLeft ? backSpeed : Input.holdButton("shift") ? runSpeed : speed), ForceMode.ACCELLERATION);
					gameObject.transform.scaleX = 1;
					gameObject.animation.reversed = isMouseOnTheLeft;
					gameObject.animation.play();
				}
				else if (Input.directional("samusDirection") < 0)
				{
					gameObject.rigidbody.addForceX(-(!isMouseOnTheLeft ? backSpeed : Input.holdButton("shift") ? runSpeed : speed), ForceMode.ACCELLERATION);
					gameObject.transform.scaleX = -1;
					gameObject.animation.reversed = !isMouseOnTheLeft;
					gameObject.animation.play();
				}
				else
				{
					gameObject.animation.gotoAndStop(4);
					gameObject.sendMessage("Audio_stop");
				}
				if (Input.pressButton("jump"))
				{
					trace("jump");
					gameObject.rigidbody.addForce(new Point(0, -jumpSpeed), ForceMode.ACCELLERATION);
				}
			}
			/*if (gameObject.transform.x > 600)
			{
				gameObject.transform.x = -600;
			}
			else if (gameObject.transform.x < -600)
			{
				gameObject.transform.x = 600;
			}*/
			
			if (isMouseOnTheLeft)
			{
				gameObject.transform.scaleX = -1;
			}
			else
			{
				gameObject.transform.scaleX = 1;
			}
		}
		
	}
	
}