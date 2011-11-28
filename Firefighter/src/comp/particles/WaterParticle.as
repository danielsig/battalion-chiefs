package comp.particles 
{
	import comp.GameCore;
	import com.battalion.flashpoint.comp.misc.PhysicsDebugger;
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
		
		private var _splashed : Boolean = false;
		
		private static var _jetMaterial : PhysicMaterial = new PhysicMaterial(0.9, 0.5);
		private static var _splashMaterial : PhysicMaterial = new PhysicMaterial(0.3, 0.5);
		
		public function awake() : void
		{
			requireComponent(RigidbodyInterpolator);
			_body = gameObject.rigidbody;
			
			_body.drag = 0.005;
			_col = gameObject.circleCollider as CircleCollider;
			_col.material = _jetMaterial;
			_col.layers = Layers.OBJECTS_VS_WATER;
			if(GameCore.difficulty == GameCore.EASY) _col.layers |= Layers.WATER_VS_FIRE;
			gameObject.transform.forward = _body.velocity;
			gameObject.renderer.offset = new Matrix(4, 0, 0, 0.7, 30, 0);
		}
		public function fixedUpdate() : void
		{	
			var contacts : Vector.<ContactPoint> = _body.contacts;
			if (!_splashed)
			{
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
			}
			else if (contacts)
			{
				for each(contact in contacts)
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
								gameObject.renderer.optimized = true;
								_col.layers = Layers.STEAM_AND_SMOKE;
								_body.affectedByGravity = false;
								destroy();
							}
							
							heat.addHeat((100 - heat.heat) * 0.3);
							
							return;
						}
						else if (other is CircleCollider && other.gameObject.flameParticle)
						{
							other.gameObject.flameParticle.extinguish();
							gameObject.animation.gotoAndPlay(gameObject.animation.playhead *  0.3, "SteamAnimation");
							gameObject.renderer.optimized = true;
							_col.layers = Layers.STEAM_AND_SMOKE;
							_body.affectedByGravity = false;
							_body.vanDerWaals = -2;
							_body.drag = 0.1;
							destroy();
							return;
						}
					}
				}
			}
			_prevX = gameObject.transform.x;
			_prevY = gameObject.transform.y;
		}
		public function splash() : void
		{
			gameObject.transform.rotation = Math.random() * 360 - 180;
			_body.addForce(new Point(Math.random() * 2 - 1, Math.random() * 2 - 1));
			_splashed = true;
			gameObject.animation.playhead = 40;
			_body.drag = 0.05;
			_body.vanDerWaals = -1;
			_body.mass *= 0.1;
			_col.radius *= 2;
			_col.layers |= Layers.WATER_VS_FIRE;
			_col.material = _splashMaterial;
			gameObject.renderer.offset = null;
		}
	}

}