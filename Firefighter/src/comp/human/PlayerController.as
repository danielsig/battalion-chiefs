package comp.human 
{
	
	import comp.particles.*;
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import com.battalion.Input;
	import flash.display.PixelSnapping;
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
			world.cam.transform.x = player.transform.x;
			world.cam.transform.y = player.transform.y;
			return player;
		}
		
		public static var cheatsEnabled : Boolean = true;// CONFIG::debug;
		
		private var _hose : GameObject;		
		private var _tr : Transform;
		private var _running : Boolean = false;
		
		public function awake() : void 
		{
			//BODY
			HumanBodyFactory.createFireFighter(gameObject);
			
			//HEAD
			(gameObject.torso.head.addComponent(LookAtMouse) as LookAtMouse).passive = true;
			
			//HANDS
			//	right hand
			var mouseLook : LookAtMouse = gameObject.torso.rightArm.addComponent(LookAtMouse) as LookAtMouse;
			mouseLook.passive = false;
			mouseLook.angleOffset = 50;
			mouseLook.transitionMultiplier = 0.3;
			mouseLook.lowerConstraints = -150;
			mouseLook.upperConstraints = 0;
			//	left hand
			mouseLook = gameObject.torso.rightArm.rightForearm.addComponent(LookAtMouse) as LookAtMouse;
			mouseLook.passive = false;
			mouseLook.angleOffset = 90;
			mouseLook.transitionMultiplier = 0.3;
			mouseLook.lowerConstraints = -150;
			mouseLook.upperConstraints = 0;
			
			//CHEATS
			if (cheatsEnabled)
			{
				requireComponent(TimeMachine);
				requireComponent(Zoomer);
			}
			
			//COMPONENTS
			_tr = gameObject.transform;
			requireComponent(Audio);
			
			//HOSE
			_hose = WaterHose.createWaterHose(0, 20, gameObject.torso.rightArm.rightForearm.rightHand);
			_hose.transform.rotation = 90;
			_hose.particleGenerator.emitting = false;
			
			//CAM
			(world.cam.addComponent(Follow) as Follow).follow(gameObject, 0.2, new Point(0, -50));
			
			//CONTROLS
			Input.assignDirectional("playerDirection", "d", "a", Keyboard.RIGHT, Keyboard.LEFT);
			Input.assignDirectional("playerVerticalDirection", "w", "s", Keyboard.UP, Keyboard.DOWN);
			Input.assignButton("shift", Keyboard.SHIFT);
			Input.assignButton("jump", Keyboard.SPACE);
			Input.assignButton("crouch", "c");
			Input.assignButton("burn", "f");
			Input.assignButton("teleport", "t");
		}
			
		public function fixedUpdate() : void 
		{
			var thisPos : Point = _tr.globalPosition;
			var mousePos : Point = world.cam.camera.screenToWorld(Input.mouse);
			
			//CONTROLS
			sendMessage("HumanBody_face" + (mousePos.x < thisPos.x ? "Left" : "Right"));
			sendMessage("HumanBody_go" + (mousePos.y < thisPos.y ? "Up" : "Down"));
			var dir : int = Input.directional("playerVerticalDirection");
			if(dir) sendMessage("HumanBody_go" + (dir > 0 ? "Up" : "Down") + "Stairs");
			dir = Input.directional("playerDirection");
			if (dir) sendMessage("HumanBody_go" + (dir > 0 ? "Right" : "Left"));
			if (_running != Input.holdButton("shift")) sendMessage("HumanBody_" + ((_running = !_running) ? "start" : "stop") + "Running");
			if (Input.pressButton("jump")) sendMessage("HumanBody_jump");
			
			if (_running || !gameObject.humanBody.grounded)
			{
				gameObject.torso.rightArm.lookAtMouse.enabled = false;
				gameObject.torso.rightArm.rightForearm.lookAtMouse.enabled = false;
			}
			else
			{
				gameObject.torso.rightArm.lookAtMouse.enabled = true;
				gameObject.torso.rightArm.rightForearm.lookAtMouse.enabled = true;
			}
			
			
			//HOSE
			if (Input.mouseHold && !_running && gameObject.humanBody.grounded)
			{
				_hose.particleGenerator.emitting = true;
			}
			else _hose.particleGenerator.emitting = false;
			
			
			//CHEATS
			if (cheatsEnabled)
			{
				if (Input.pressButton("teleport"))
				{
					_tr.x = Transform.mouseWorldX;
					_tr.y = Transform.mouseWorldY - 50;
				}
				if (Input.pressButton("burn"))
				{
					Fire.createFire(Transform.mouseWorldX, Transform.mouseWorldY);
				}
			}
			
		}
		
	}
	
}