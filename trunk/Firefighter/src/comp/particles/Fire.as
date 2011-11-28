package comp.particles 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.comp.misc.*;
	import flash.geom.Point;
	
	/**
	 * @author Battalion Chiefs
	 */
	public class Fire extends Component implements IExclusiveComponent 
	{
		public static function createFire(x : Number = 0, y : Number = 0, objOnFire : GameObject = null) : GameObject
		{
			if (!objOnFire)
			{
				objOnFire = new GameObject("fire", Fire, ParticleGenerator);
			}
			else
			{
				objOnFire.addComponent(Fire);
				var collider : Collider = (objOnFire.circleCollider || objOnFire.boxCollider || objOnFire.triangleCollider) as Collider;
				if (collider)
				{
					objOnFire.fire._preLayers = collider.groupLayers;
					collider.groupLayers &= ~(Layers.OBJECTS_VS_FIRE | Layers.FIRE_VS_HUMANS);
				}
			}
			objOnFire.transform.x = x;
			objOnFire.transform.y = y;
			return objOnFire;
		}
		
		private var _preLayers : uint = 0;
		private var _gen : ParticleGenerator;
		private var _heat : Heat;
		private var _emitting : Boolean = true;
		private static var _init : Boolean = true;
		private static var _fireMaterial : PhysicMaterial = new PhysicMaterial(0.0, 0.8);
		
		public function awake() : void
		{
			if (_init)
			{
				_init = false;
				Animation.load("FireAnimation", "assets/img/fire.png~0-80~");
				Animation.addLabel("FireAnimation", "destroyer", 80);
				Animation.addLabel("FireAnimation", "shrinkFire", 50);
				Animation.load("SmokeAnimation", "assets/img/smoke.png~0-62~");
				Animation.addLabel("SmokeAnimation", "destroyer", 62);
			}
			_heat = requireComponent(Heat) as Heat;
			_heat.heat = _heat.firePoint;
			
			_gen = requireComponent(ParticleGenerator) as ParticleGenerator;
			_gen.graphicsName = "FireAnimation";
			_gen.isAnimation = true;
			_gen.randomVelocity = new Point(10, 10);
			_gen.radius = 23;
			_gen.mass = 0.5;
			_gen.hz = _heat.combustionRate;
			_gen.maxParticleCount = uint.MAX_VALUE;
		}
		
		public function onEmit(particle : GameObject) : void
		{
			particle.addComponent(FlameParticle);
			particle.flameParticle.heat = _heat;
			particle.circleCollider.material = _fireMaterial;
			particle.addConcise(Destroyer, "destroyer");
			if (_heat.heat < _heat.firePoint) _heat.heat += 50;
		}
		public function fixedUpdate() : void
		{
			_gen.emitting = FlameParticle.particleCounter < FlameParticle.MAX_PARTICLES && (world.cam.camera as Camera).inSight(gameObject.transform.x, gameObject.transform.y - 400, 600, 1200) && _emitting;
			if (_heat.heat < _heat.flashPoint)
			{
				var collider : Collider = (gameObject.circleCollider || gameObject.boxCollider || gameObject.triangleCollider) as Collider;
				if (collider) collider.groupLayers = _preLayers;
				
				if (gameObject.name == "fire")
				{
					gameObject.destroy();
				}
				else
				{
					destroy();
					_gen.destroy();
				}
			}
		}
		public function toggleFire() : void
		{
			_emitting = !_emitting;
		}
	}

}