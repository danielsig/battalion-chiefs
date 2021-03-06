package comp.particles 
{
	import comp.GameCore;
	import com.battalion.flashpoint.comp.Animation;
	import com.battalion.flashpoint.comp.Renderer;
	import com.battalion.flashpoint.core.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * @author Battalion Chiefs
	 */
	public final class FlameParticle extends Component implements IExclusiveComponent 
	{
		internal static const MAX_PARTICLES : uint = 400;
		internal static var particleCounter : uint = 0;
		private static var _flameMaterial : PhysicMaterial = new PhysicMaterial(0.9, 0.9);
		
		private var _body : Rigidbody;
		private var _col : CircleCollider;
		private var _rotationOffset : Number = (Math.random() * 360) - 180;
		private var _tr : Transform;
		private var _optimized : Boolean = false;
		
		public var fluctuation : Number = 20;
		public var upDraft : Number = 10;
		internal var heat : Heat = null;
		
		private var _particleAdder : uint = particleCounter++;
		
		public function awake() : void
		{	
			_tr = gameObject.transform;
			requireComponent(RigidbodyInterpolator);
			_body = gameObject.rigidbody;
			_body.affectedByGravity = false;
			_body.vanDerWaals = -1.5;
			_body.drag = 0.01;
			
			gameObject.renderer.optimized = false;
			
			_col = gameObject.circleCollider as CircleCollider;
			_col.material = _flameMaterial;
			_col.layers = Layers.OBJECTS_VS_FIRE | Layers.WATER_VS_FIRE | Layers.STEAM_AND_SMOKE | Layers.FIRE_VS_HUMANS;
			setFunctionPointer("fixedUpdate", flameUpdate);
			setFunctionPointer("onCollisionEnter", collisionEnter);
		}
		public var fixedUpdate : Function = flameUpdate;
		private function smokeUpdate() : void
		{
			_body.addForceY( -100, ForceMode.ACCELLERATION);
			gameObject.renderer.priority -= FlashPoint.fixedDeltaTime;
		}
		private function flameUpdate() : void
		{
			var random : Point = new Point(Math.random() * fluctuation - fluctuation * 0.5, Math.random() * fluctuation - fluctuation * 0.5 - upDraft);
			_body.addForce(random, ForceMode.ACCELLERATION);
			var rotation : Number =  _tr.rotation;
			_tr.rotateTowards(_tr.position.add(_body.velocity), _rotationOffset);
			_body.angularVelocity = _tr.rotation - rotation;
			var nowOptimized : Boolean = particleCounter >= MAX_PARTICLES;
			if (nowOptimized != _optimized) gameObject.renderer.optimized = _optimized = nowOptimized;
			gameObject.renderer.priority -= FlashPoint.fixedDeltaTime * (gameObject.renderer.priority - 30) * 0.5;
		}
		public function extinguish() : void
		{
			_body.vanDerWaals = 0;
			_body.drag = 2;
			var frame : uint = gameObject.animation.playhead;
			heat.heat -= (80 - gameObject.animation.playhead) * (5 - GameCore.difficulty) * 0.28;
			gameObject.animation.gotoAndPlay(frame *  0.3, "SmokeAnimation");
			gameObject.renderer.optimized = true;
			gameObject.renderer.priority = 80;
			_col.layers = Layers.STEAM_AND_SMOKE;
			setFunctionPointer("fixedUpdate", smokeUpdate);
			setFunctionPointer("onCollisionEnter", null);
		}
		public function onDestroy() : void
		{
			_body = null;
			_col = null;
			_tr = null;
			heat = null;
			
			particleCounter--;
		}
		public function recycleParticle() : void
		{
			//particleCounter--;
			setFunctionPointer("fixedUpdate", null);
			setFunctionPointer("onCollisionEnter", null);
		}
		public function shrinkFire() : void
		{
			_col.radius *= 0.6;
		}
		public var onCollisionEnter : Function = collisionEnter;
		private function collisionEnter(contacts : Vector.<ContactPoint>) : void
		{
			for each(var contact : ContactPoint in contacts)
			{
				if (!contact.otherCollider) continue;
				var otherObj : GameObject = contact.otherCollider.gameObject;
				if (otherObj.heat && !otherObj.fire)
				{
					otherObj.heat.addHeat((80 - gameObject.animation.playhead) * 0.05);
				}
			}
		}
	}

}