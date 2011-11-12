package comp 
{
	
	import com.battalion.flashpoint.comp.Audio;
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
		public static var cheatsEnabled : Boolean = true;// CONFIG::debug;
		public var speed : Number = 160;
		public var backSpeed : Number = 100;
		public var runSpeed : Number = 240;
		public var jumpSpeed : Number = 300;
		public var inAir : Boolean = true;
		
		public function awake() : void 
		{
			if (cheatsEnabled)
			{
				requireComponent(TimeMachine);
				requireComponent(Zoomer);
			}
			(requireComponent(Rigidbody) as Rigidbody);
			(world.cam.addComponent(Follow) as Follow).follow(gameObject, 0.06, new Point(0, -50));
			
			Input.assignDirectional("samusDirection", "d", "a", Keyboard.RIGHT, Keyboard.LEFT);
			Input.assignButton("shift", Keyboard.SHIFT);
			Input.assignButton("jump", Keyboard.SPACE);
			Input.assignButton("crouch", "c");
			Input.assignButton("burn", "f");
			/*
			Input.assignButton("CHEAT1", "C");
			Input.assignButton("CHEAT2", "H");
			Input.assignButton("CHEAT3", "E");
			Input.assignButton("CHEAT4", "A");
			Input.assignButton("CHEAT5", "T");
			*/
			gameObject.transform.scaleY = 3;
			addComponent(RigidbodyInterpolator);
		}
			
		public function fixedUpdate() : void 
		{
			/*if (!cheatsEnabled && Input.toggledButton("CHEAT1") && Input.toggledButton("CHEAT2") && Input.toggledButton("CHEAT3") && Input.toggledButton("CHEAT4") && Input.toggledButton("CHEAT5"))
			{
				cheatsEnabled = true;
				requireComponent(TimeMachine);
				requireComponent(Zoomer);
			}*/
			var stopAudio : Boolean = false;
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
				else if (!inAir)
				{
					gameObject.animation.gotoAndPause(4);
					sendMessage("Audio_stop");
				}
				else
				{
					inAir = false;
					sendMessage("Audio_gotoAndPlay", 200);
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
				inAir = true;
				gameObject.animation.gotoAndPause(5);
			}
			if (isMouseOnTheLeft)
			{
				gameObject.transform.scaleX = -3;
			}
			else
			{
				gameObject.transform.scaleX = 3;
			}
			if (Input.mouseClick && cheatsEnabled)
			{
				gameObject.transform.x += world.cam.transform.mouseRelativeX;
				gameObject.transform.y += world.cam.transform.mouseRelativeY - 50;
			}
			if (Input.pressButton("burn")) sendMessage("ParticleGenerator_toggleEmitting");
		}
		
	}
	
}