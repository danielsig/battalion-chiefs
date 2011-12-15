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
				Animation.load("FireAnimation", 60, "assets/img/fire.png~0-80~");
				Animation.addLabel("FireAnimation", "recycleParticle", 80);
				Animation.addLabel("FireAnimation", "shrinkFire", 50);
				Animation.load("SmokeAnimation", 12, "assets/img/smoke.png~0-62~");
				Animation.addLabel("SmokeAnimation", "recycleParticle", 62);
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
					collider.removeLayers(Layers.OBJECTS_VS_FIRE | Layers.FIRE_VS_HUMANS);
				}
			}
			objOnFire.transform.x = x;
			objOnFire.transform.y = y;
			return objOnFire;
		}
		
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
			_gen.graphicsPriority = 90;
			_gen.randomVelocity = new Point(10, 10);
			_gen.radius = 23;
			_gen.mass = 0.5;
			_gen.hz = _heat.combustionRate;
			_gen.recycle = true;
		}
		public function onEmit(particle : GameObject) : void
		{
			particle.addComponent(FlameParticle);
			particle.flameParticle.heat = _heat;
			particle.circleCollider.material = _fireMaterial;
			if (_heat.heat < _heat.firePoint) _heat.heat += 50;
			_gen.graphicsPriority = _gen.graphicsPriority == 80 ? 120 : 80;
		}
		public function onRecycle(particle : GameObject) : void
		{
			particle.flameParticle.awake();
			particle.flameParticle.heat = _heat;
			particle.circleCollider.material = _fireMaterial;
			if (_heat.heat < _heat.firePoint) _heat.heat += 50;
			_gen.graphicsPriority = _gen.graphicsPriority == 80 ? 120 : 80;
		}
		public function fixedUpdate() : void
		{
			var inSight : Boolean = world.cam ? (world.cam.camera as Camera).inSight(gameObject.transform.x, gameObject.transform.y - 400, 600, 800) : false;
			var hearable : Boolean = world.cam ? (world.cam.camera as Camera).inSight(gameObject.transform.x, gameObject.transform.y - 400, 800, 800) : false;
			_gen.emitting = FlameParticle.particleCounter < FlameParticle.MAX_PARTICLES && inSight && _emitting;
			if (_heat.heat < _heat.flashPoint)
			{
				var collider : Collider = (gameObject.circleCollider || gameObject.boxCollider || gameObject.triangleCollider) as Collider;
				if (collider) collider.addLayers(gameObject.humanBody ? Layers.FIRE_VS_HUMANS : Layers.OBJECTS_VS_FIRE);
				
				if (gameObject.name == "fire")
				{
					var g : GameObject = gameObject;
					destroy();
					g.destroy();			
				}
				else
				{
					destroy();
				}
				return;
			}
			if (!_soundEffects && hearable && _available)
			{
				_available--;
				gameObject.audio.volumeFalloff = 1;
				sendMessage("Audio_gotoAndPlay", Math.random() * 1531, "fireburn");
				_soundEffects = true;
			}
			else if (_soundEffects && !hearable)
			{
				_available++;
				gameObject.audio.volumeFalloff = 1;
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
				gameObject.audio.volumeFalloff = 1;
				sendMessage("Audio_stop");
			}
			releaseComponent(ParticleGenerator).destroy();
			_gen = null;
			var collider : Collider = (gameObject.circleCollider || gameObject.boxCollider || gameObject.triangleCollider) as Collider;
			if (collider)
			{
				collider.addLayers(Layers.OBJECTS_VS_FIRE | Layers.FIRE_VS_HUMANS);
			}
			return false;
		}
	}

}