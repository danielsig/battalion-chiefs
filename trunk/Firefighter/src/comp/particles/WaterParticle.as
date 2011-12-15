package comp.particles 
{
	import com.battalion.flashpoint.comp.Animation;
	import comp.GameCore;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.comp.tools.PhysicsDebugger;
	import com.battalion.flashpoint.core.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * @author Battalion Chiefs
	 */
	public final class WaterParticle extends Component implements IExclusiveComponent 
	{
		
		private var _body : Rigidbody;
		private var _col : CircleCollider;
		
		private var _prevX : Number = 0;
		private var _prevY : Number = 0;
		
		private var _splashed : Boolean;
		
		private static var _jetMaterial : PhysicMaterial = new PhysicMaterial(0.9, 0.5);
		private static var _splashMaterial : PhysicMaterial = new PhysicMaterial(0.3, 0.5);
		
		public function awake() : void
		{
			if(!gameObject.rigidbodyInterpolator) requireComponent(RigidbodyInterpolator);
			_body = gameObject.rigidbody;
			_body.freezeRotation = true;
			
			_col = gameObject.circleCollider as CircleCollider;
			_col.material = _jetMaterial;
			_col.layers = Layers.OBJECTS_VS_WATER | Layers.STEAM_AND_SMOKE;
			if (GameCore.difficulty == GameCore.EASY) _col.layers |= Layers.WATER_VS_FIRE;
			
			gameObject.transform.forward = _body.velocity;
			
			gameObject.renderer.optimized = false;
			gameObject.renderer.offset = new Matrix(4, 0, 0, 0.7, 30, 0);
			gameObject.renderer.updateBitmap = true;
			
			_splashed = false;
			if (fixedUpdate != preSplash) setFunctionPointer("fixedUpdate", preSplash);
			sendBefore("onStart", "fixedUpdate");
		}
		public function onStart() : void
		{
			_prevX = gameObject.rigidbodyInterpolator.previousX;
			_prevY = gameObject.rigidbodyInterpolator.previousY;
		}
		public var fixedUpdate : Function = preSplash;
		private function preSplash() : void
		{
			var contacts : Vector.<ContactPoint> = _body.contacts;
			var vx : Number = gameObject.transform.x - _prevX;
			var vy : Number = gameObject.transform.y - _prevY;
			if (gameObject.animation.playhead > 2 && vx * vx + vy * vy < 0.01) splash();
			else if (contacts)
			{
				for each(var contact : ContactPoint in contacts)
				{
					if (!contact.otherCollider || (!contact.otherCollider.isDestroyed && (!contact.otherCollider.gameObject.waterParticle || contact.otherCollider.gameObject.waterParticle._splashed)))
					{
						splash();
						break;
					}
				}
			}
			gameObject.transform.forward = _body.velocity;
			
			_prevX = gameObject.transform.x;
			_prevY = gameObject.transform.y;
		}
		private function postSplash() : void
		{
			var contacts : Vector.<ContactPoint> = _body.contacts;
			if (contacts)
			{
				for each(var contact : ContactPoint in contacts)
				{
					var other : Collider = contact.otherCollider;
					if (other && !other.isDestroyed)
					{
						var heat : Heat = contact.otherCollider.gameObject.heat;
						if (heat)
						{
							if (heat.heat > heat.flashPoint)
							{
								gameObject.animation.gotoAndPlay(gameObject.animation.playhead *  0.3, "SteamAnimation");
								gameObject.renderer.optimized = gameObject.renderer.updateBitmap = true;
								gameObject.renderer.offset = null;
								gameObject.renderer.priority = 50;
								_col.layers = Layers.STEAM_AND_SMOKE;
								_col.radius = 8;
								_body.affectedByGravity = false;
								_body.vanDerWaals = -20;
								_body.drag = 2;
								setFunctionPointer("fixedUpdate", steamUpdate);
							}
							
							heat.addHeat((100 - heat.heat) * 0.3);
							
							return;
						}
						else if (other is CircleCollider && other.gameObject.flameParticle && (other.gameObject.animation as Animation).currentName != "SmokeAnimation")
						{
							other.gameObject.flameParticle.extinguish();
							gameObject.animation.gotoAndPlay(gameObject.animation.playhead *  0.3, "SteamAnimation");
							gameObject.renderer.optimized = gameObject.renderer.updateBitmap = true;
							gameObject.renderer.offset = null;
							_col.layers = Layers.STEAM_AND_SMOKE;
							_col.radius = 8;
							_body.affectedByGravity = false;
							_body.vanDerWaals = -20;
							_body.drag = 2;
							setFunctionPointer("fixedUpdate", steamUpdate);
							return;
						}
					}
				}
			}
			_prevX = gameObject.transform.x;
			_prevY = gameObject.transform.y;
		}
		private function steamUpdate() : void
		{
			_body.addForceY( -100, ForceMode.ACCELLERATION);
			gameObject.renderer.priority -= FlashPoint.fixedDeltaTime * 3;
		}
		public function splash() : void
		{
			gameObject.animation.play();
			(gameObject.renderer as Renderer).setOffsetRotation(0, 0, 1, Math.random() * 360 - 180);
			_body.addForce(new Point(Math.random() * 2 - 1, Math.random() * 2 - 1));
			_splashed = true;
			gameObject.animation.playhead = 40;
			_body.drag = 0;
			_body.vanDerWaals = -30;
			_body.freezeRotation = false;
			_body.mass *= 0.1;
			_col.radius *= 2;
			_col.layers |= Layers.WATER_VS_FIRE;
			_col.material = _splashMaterial;
			setFunctionPointer("fixedUpdate", postSplash);
		}
		public function shrink() : void
		{
			_col.radius = 5;
		}
		public function recycleParticle() : void
		{
			setFunctionPointer("fixedUpdate", null);
		}
	}

}