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
		private static var _init : Boolean = init();
		private static var _available : int = 7;
		
		private static function init() : Boolean
		{
				Audio.load("fireburn", "assets/sound/sounds.mp3~852-2383~");
				Animation.load("FireAnimation", "assets/img/fire.png~0-80~");
				Animation.addLabel("FireAnimation", "destroyer", 80);
				Animation.addLabel("FireAnimation", "shrinkFire", 50);
				Animation.load("SmokeAnimation", "assets/img/smoke.png~0-62~");
				Animation.addLabel("SmokeAnimation", "destroyer", 62);
				return true;
		}
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
		
		private var _soundEffects : Boolean = false;
		
		private static var _fireMaterial : PhysicMaterial = new PhysicMaterial(0.0, 0.8);
		
		public function awake() : void
		{	
			requireComponent(Audio);
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
			var inSight : Boolean = (world.cam.camera as Camera).inSight(gameObject.transform.x, gameObject.transform.y - 400, 600, 1200);
			var hearable : Boolean = (world.cam.camera as Camera).inSight(gameObject.transform.x, gameObject.transform.y - 400, 1200, 1200);
			_gen.emitting = FlameParticle.particleCounter < FlameParticle.MAX_PARTICLES && inSight && _emitting;
			if (_heat.heat < _heat.flashPoint)
			{
				var collider : Collider = (gameObject.circleCollider || gameObject.boxCollider || gameObject.triangleCollider) as Collider;
				if (collider) collider.groupLayers = _preLayers;
				
				if (gameObject.name == "fire")
				{
					gameObject.destroy();
					_gen = null;
					return;
				}
				else
				{
					destroy();
					_gen.destroy();
					_gen = null;
					return;
				}
				_emitting = false;
			}
			if (!_soundEffects && hearable && _available)
			{
				_available--;
				sendMessage("Audio_gotoAndPlay", Math.random() * 1531, "fireburn");
				_soundEffects = true;
			}
			else if (_soundEffects && !hearable)
			{
				_available++;
				sendMessage("Audio_stop");
				_soundEffects = false;
			}
			
		}
		public function toggleFire() : void
		{
			_emitting = !_emitting;
		}
		public function onDestroy() : Boolean
		{
			if (_soundEffects)
			{
				_available++;
				sendMessage("Audio_stop");
			}
			return false;
		}
	}

}