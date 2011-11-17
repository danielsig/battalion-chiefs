package comp.human 
{
	
	import comp.particles.*;
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.Input;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	/**
	 * @author Battalion Chiefs
	 */
	public class PlayerController extends Component implements IExclusiveComponent
	{
		
		public static function createPlayer(x : Number = 0, y : Number = 0) : GameObject 
		{
			var player : GameObject = new GameObject("player", PlayerController);
			player.transform.x = x;
			player.transform.y = y;
			return player;
		}
		
		public static var cheatsEnabled : Boolean = true;// CONFIG::debug;
		public var speed : Number = 160;
		public var backSpeed : Number = 100;
		public var runSpeed : Number = 240;
		public var jumpSpeed : Number = 300;
		
		private var _inAir : Boolean = true;
		private var _hose : GameObject;
		private var _animation : BoneAnimation;
		private var _rigidbody : Rigidbody;
		
		private var _tr : Transform;
		
		public function awake() : void 
		{
			//BODY
			Renderer.drawBox("limb", 20, 26, 0x0000FF);
			
			Renderer.drawBox("torso", 28, 44);
			Renderer.drawBox("head", 20, 26);
			
			HumanBody.addBody(gameObject, "torso", "head", "limb", "limb");
			
			//HEAD
			(gameObject.torso.head.addComponent(LookAtMouse) as LookAtMouse).passive = true;
			
			//CHEATS
			if (cheatsEnabled)
			{
				requireComponent(TimeMachine);
				requireComponent(Zoomer);
			}
			
			//COMPONENTS
			_tr = gameObject.transform;
			_rigidbody = requireComponent(Rigidbody) as Rigidbody;
			_animation = gameObject.torso.boneAnimation;
			requireComponent(Audio);
			requireComponent(BoxCollider);
			requireComponent(RigidbodyInterpolator);
			
			//PHSYICS
			gameObject.boxCollider.dimensions = new Point(62, 126);
			gameObject.boxCollider.material = new PhysicMaterial(0.1, 0);
			_rigidbody.mass = 50;
			_rigidbody.drag = 0;
			_rigidbody.freezeRotation = true;
			
			//HOSE
			_hose = WaterHose.createWaterHose(10, -35, gameObject);
			_hose.particleGenerator.emitting = false;
			_hose.addComponent(LookAtMouse);
			
			//CAM
			(world.cam.addComponent(Follow) as Follow).follow(gameObject, 0.06, new Point(0, -50));
			
			//CONTROLS
			Input.assignDirectional("playerDirection", "d", "a", Keyboard.RIGHT, Keyboard.LEFT);
			Input.assignButton("shift", Keyboard.SHIFT);
			Input.assignButton("jump", Keyboard.SPACE);
			Input.assignButton("crouch", "c");
			Input.assignButton("burn", "f");
			Input.assignButton("teleport", "t");
			
			//STARTING IDLE ANIMATION
			_animation.play("humanIdle");
		}
			
		public function fixedUpdate() : void 
		{
			var stopAudio : Boolean = false;
			var thisPos : Point = _tr.globalPosition;
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			var isMouseOnTheLeft : Boolean = mousePos.x < thisPos.x;
			
			var points : Vector.<ContactPoint> = _rigidbody.touchingInDirection(new Point(0, 1), 0.01);
			if (points)
			{
				if (Input.directional("playerDirection") > 0)
				{
					_rigidbody.addForceX((isMouseOnTheLeft ? backSpeed : Input.holdButton("shift") ? runSpeed : speed), ForceMode.ACCELLERATION);
					_tr.scaleX = 1;
					//_animation.reversed = isMouseOnTheLeft;
					_animation.play("humanRun");
				}
				else if (Input.directional("playerDirection") < 0)
				{
					_rigidbody.addForceX(-(!isMouseOnTheLeft ? backSpeed : Input.holdButton("shift") ? runSpeed : speed), ForceMode.ACCELLERATION);
					_tr.scaleX = -1;
					//_animation.reversed = !isMouseOnTheLeft;
					_animation.play("humanRun");
				}
				else if (!_inAir)
				{
					_animation.play("humanIdle");
					sendMessage("Audio_stop");
				}
				else
				{
					_inAir = false;
					sendMessage("Audio_gotoAndPlay", 200);
				}
				if (Input.pressButton("jump"))
				{
					_rigidbody.addForce(new Point(0, -jumpSpeed), ForceMode.ACCELLERATION);
				}
				if (Input.pressButton("crouch"))
				{
					_rigidbody.addForce(new Point(0, jumpSpeed), ForceMode.ACCELLERATION);
				}
			}
			else
			{
				_inAir = true;
				//_animation.gotoAndPause(5);
			}
			if (isMouseOnTheLeft)
			{
				_tr.scaleX = -1;
			}
			else
			{
				_tr.scaleX = 1;
			}
			if (cheatsEnabled)
			{
				if (Input.pressButton("teleport"))
				{
					_tr.x += world.cam.transform.mouseRelativeX;
					_tr.y += world.cam.transform.mouseRelativeY - 50;
				}
				if (Input.pressButton("burn"))
				{
					Fire.createFire(_tr.x, _tr.y + 20);
				}
			}
			
			if (Input.mouseHold)
			{
				_hose.particleGenerator.emitting = true;
			}
			else _hose.particleGenerator.emitting = false;
			
		}
		
	}
	
}