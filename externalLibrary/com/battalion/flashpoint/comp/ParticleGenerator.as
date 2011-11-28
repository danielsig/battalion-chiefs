package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.*;
	import flash.geom.Point;
	/**
	 * Use this for awesome particle effects.
	 * @author Battalion Chiefs
	 */
	public final class ParticleGenerator extends Component
	{
		
		public var maxParticleCount : uint = uint.MAX_VALUE;
		
		/**
		 * Set this to a Point so that the ParticleGenerator will add a rigidbody to the
		 * GameObject. The values will determine the initial velocity of the rigidbody.
		 */
		public var velocity : Point = null;
		
		/**
		 * Set this to a Point so that the ParticleGenerator will add a rigidbody to the
		 * GameObject. The values will determine the initial random velocity of the rigidbody.
		 * e.g. a Point(0, 10) will cause the velocity along Y axis to range between -10 and 10.
		 */
		public var randomVelocity : Point = null;
		
		/**
		 * Set this to a a non-zero value so that the ParticleGenerator will add a rigidbody to the
		 * GameObject. The values will determine the mass of the rigidbody.
		 */
		public var mass : Number = 0;
		
		/**
		 * Set this to a a non-zero value so that the ParticleGenerator will add a rigidbody to the
		 * GameObject. The values will determine the inertia of the rigidbody.
		 */
		public var inertia : Number = 0;
		
		/**
		 * Setting this to false will pause the generation of particles.
		 */
		public var emitting : Boolean = true;
		
		/**
		 * Set this to a non-zero value so that the ParticleGenerator will add a CircleCollider to the
		 * GameObject. The value determines the radius of the CircleCollider.
		 */
		public var radius : Number = 0;
		
		public var graphicsName : String = null;
		public var isAnimation : Boolean = false;
		
		/**
		 * The amount of particles to generate per second.
		 */
		public var hz : Number = 10;
		
		/** @private **/
		internal var _counter : uint = 0;
		
		/** @private **/
		internal var _latestParticle : ParticleHandler;
		
		private var _random : Number = 0;
		
		private var _hzCount : Number = 0.000001;
		
		private var _prevVelocityX : Number = 0;
		private var _prevVelocityY : Number = 0;
		
		public function start() : void
		{
			emitting = true;
		}
		public function stop() : void
		{
			emitting = false;
		}
		public function toggleEmitting() : void
		{
			emitting = !emitting;
		}
		
		/** @private **/
		public function fixedUpdate() : void
		{
			if (emitting)
			{
				_hzCount++;
				var framesPerGen : Number = FlashPoint.fixedFPS / hz;
				while (_hzCount > framesPerGen)
				{
					_hzCount -= framesPerGen;
					_counter++;
					
					var particle : GameObject = new GameObject(gameObject.name + "Particle" + _counter);
					particle.transform.x = gameObject.transform.gx;
					particle.transform.y = gameObject.transform.gy;
					if (maxParticleCount != uint.MAX_VALUE)
					{
						var handler : ParticleHandler = particle.addComponent(ParticleHandler) as ParticleHandler;
						handler._generator = this;
						handler._next = _latestParticle;
						if(_latestParticle) _latestParticle._prev = handler;
						_latestParticle = handler;
					}
					if (radius > 0)
					{
						var col : CircleCollider = particle.addComponent(CircleCollider) as CircleCollider;
						col.radius = radius;
					}
					if (velocity || randomVelocity || mass || inertia)
					{
						var body : Rigidbody = particle.addComponent(Rigidbody) as Rigidbody;
						if (velocity) body.velocity = new Point(velocity.x * (1 - _hzCount) + _prevVelocityX * _hzCount, velocity.y * (1 - _hzCount) + _prevVelocityY * _hzCount);
						if (randomVelocity)
						{
							var randomVel : Point = body.velocity;
							randomVel.offset((_random = ((1 + (_random * 12414)) % 43231)) * 0.0000462630982 * randomVelocity.x - randomVelocity.x, (_random = ((1 + (_random * 12414)) % 43231)) * 0.0000462630982 * randomVelocity.y - randomVelocity.y);
							body.velocity = randomVel;
						}
						particle.sendBefore("RigidbodyInterpolator_setPrevious", "update", particle.transform.x, particle.transform.y);
						particle.transform.x += body.velocity.x * _hzCount * 0.16;
						particle.transform.y += body.velocity.y * _hzCount * 0.16;
						if (mass) body.mass = mass;
						if (inertia) body.inertia = inertia;
					}
					if (graphicsName)
					{
						var renderer : Renderer = particle.addComponent(Renderer) as Renderer;
						if (isAnimation)
						{
							var animation : Animation = particle.addComponent(Animation) as Animation;
							animation.play(graphicsName);
						}
						else renderer.setBitmapByName(graphicsName);
					}
					
					//particle.log();
					sendMessage("onEmit", particle);
				}
			}
			if (velocity)
			{
				_prevVelocityX = velocity.x;
				_prevVelocityY = velocity.y;
			}
		}
		/** @private **/
		public function onDestroy() : Boolean
		{
			velocity = randomVelocity = null;
			graphicsName = null;
			_latestParticle = null;
			return false;
		}
	}
}