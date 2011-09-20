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
		
		public var speed : Number = 10;
		public var backSpeed : Number = 7;
		public var runSpeed : Number = 20;
		
		public function awake() : void 
		{
			requireComponent(TimeMachine);
			
			Input.assignDirectional("samusDirection", "d", "a", Keyboard.RIGHT, Keyboard.LEFT);
			Input.assignButton("shift", Keyboard.SHIFT);
			Animation.load("samusRunning", "assets/img/samus.png~0-9~");
			gameObject.animation.play("samusRunning");
		}
		
		public function fixedUpdate() : void 
		{
			
			var thisPos : Point = (gameObject.transform as Transform).globalPosition;
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			var isMouseOnTheLeft : Boolean = mousePos.x < thisPos.x;
			
			if (Input.directional("samusDirection") > 0)
			{
				gameObject.transform.x += isMouseOnTheLeft ? backSpeed : Input.holdButton("shift") ? runSpeed : speed;
				gameObject.transform.scaleX = 1;
				gameObject.animation.reversed = isMouseOnTheLeft;
				gameObject.animation.play();
			}
			else if (Input.directional("samusDirection") < 0)
			{
				gameObject.transform.x -= !isMouseOnTheLeft ? backSpeed : Input.holdButton("shift") ? runSpeed : speed;
				gameObject.transform.scaleX = -1;
				gameObject.animation.reversed = !isMouseOnTheLeft;
				gameObject.animation.play();
			}
			else
			{
				gameObject.animation.gotoAndStop(4);
				gameObject.sendMessage("Audio_stop");
			}
			if (gameObject.transform.x > 600)
			{
				gameObject.transform.x = -600;
			}
			else if (gameObject.transform.x < -600)
			{
				gameObject.transform.x = 600;
			}
			
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