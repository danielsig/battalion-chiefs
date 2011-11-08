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
		
		public var speed : Number = 60;
		public var backSpeed : Number = 30;
		public var runSpeed : Number = 120;
		public var jumpSpeed : Number = 600;
		
		public function awake() : void 
		{
			requireComponent(TimeMachine);
			requireComponent(Zoomer);
			(requireComponent(Rigidbody) as Rigidbody);
			(world.cam.addComponent(Follow) as Follow).follow(gameObject, 0.06, new Point(0, -100));
			
			Input.assignDirectional("samusDirection", "d", "a", Keyboard.RIGHT, Keyboard.LEFT);
			Input.assignButton("shift", Keyboard.SHIFT);
			Input.assignButton("jump", Keyboard.SPACE);
			Input.assignButton("crouch", "c");
			gameObject.transform.scaleY = 3;
		}
			
		public function fixedUpdate() : void 
		{
			var thisPos : Point = (gameObject.transform as Transform).globalPosition;
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			var isMouseOnTheLeft : Boolean = mousePos.x < thisPos.x;
			
			var points : Vector.<ContactPoint> = gameObject.rigidbody.touchingInDirection(new Point(0, 1), 0.6);
			if (points)
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
					gameObject.animation.gotoAndPause(4);
					gameObject.sendMessage("Audio_stop");
				}
				if (Input.pressButton("jump"))
				{
					gameObject.rigidbody.addForce(new Point(0, -jumpSpeed), ForceMode.ACCELLERATION);
				}
				if (Input.pressButton("crouch"))
				{
					gameObject.rigidbody.addForce(new Point(0, jumpSpeed), ForceMode.ACCELLERATION);
				}
			}
			else
			{
				gameObject.animation.gotoAndPause(4);
			}
			if (isMouseOnTheLeft)
			{
				gameObject.transform.scaleX = -3;
			}
			else
			{
				gameObject.transform.scaleX = 3;
			}
		}
		
	}
	
}