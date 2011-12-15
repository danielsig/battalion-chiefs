package com.battalion.flashpoint.comp 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.powergrid.PowerGrid;
	import flash.geom.Point;
	/**
	 * Use this for awesome particle effects.
	 * Messages sent:
		 * onEmit(particle : GameObject)
		 * onRecycle(particle : GameObject)
	 * @author Battalion Chiefs
	 */
	public final class ParticleGenerator extends Component
	{
		
		public var maxParticleCount : uint = uint.MAX_VALUE;
		
		/**
		 * This value will <b>not</b> determine if a rigidbody will be added to each particle,
		 * it only determines if the rigidbody should be affected by gravity
		 * <b>IN CASE</b> a rigidbody is added. The velocity, randomVelocity, mass and
		 * inertia determine if a rigidbody should be added to each particle.
		 * @see #velocity
		 * @see #randomVelocity
		 * @see #mass
		 * @see #inertia
		 */
		public var affectedByGravity : Boolean = true;
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
		
		/**
		 * The rendering priority of this renderer of each particle. In case the number of renderers visible at any given time 
		 * exceed this value, the particle will become invisible.
		 * @see Renderer.priority
		 */
		public var graphicsPriority : uint = 300;
		/**
		 * The name of the bitmapData or animation to use for each particle.
		 * Null means no renderer nor animation will be added
		 * @see #isAnimation
		 * @see Renderer.setBitmapByName()
		 */
		public var graphicsName : String = null;
		/**
		 * Set this to true if the <code>graphicsName</code> property is in fact a name for an animation, not a bitmap.
		 * @see #graphicsName
		 */
		public var isAnimation : Boolean = false;
		/**
		 * Set this to true in order to reuse particles instead of destroying them and
		 * creating new ones (much faster since it avoids further memory allocations).
		 * To recycle an old particle, it must send a message named "recycleParticle"
		 * with the sendMessage() method. Also, when the old particle will finally be
		 * used again, this ParticleGenerator will send an "onRecycle" message instead
		 * of "onEmit".
		 * @see Component.sendMessage();
		 */
		public var recycle : Boolean = false;
		
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
		private var _prevPosX : Number = 0;
		private var _prevPosY : Number = 0;
		private var _prevRotation : Number = 0;
		
		private var _particleRecycleHead : DynamicComponent = null;
		
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
			var posX : Number = gameObject.transform.globalMatrix.tx;
			var posY : Number = gameObject.transform.globalMatrix.ty;
			var rotation : Number = gameObject.transform.globalRotation;
			if (rotation - _prevRotation > 180) _prevRotation += 360;
			else if (rotation - _prevRotation < -180) _prevRotation -= 360;
			
			if (emitting)
			{
				var amount : Number = 1 / hz;
				_hzCount += FlashPoint.fixedDeltaTime;
				if (velocity)
				{
					var len : Number = velocity.length / Math.sqrt(_prevVelocityX * _prevVelocityX + _prevVelocityY * _prevVelocityY);
					_prevVelocityX *= len;
					_prevVelocityY *= len;
				}
				while (_hzCount > amount)
				{
					_hzCount -= amount;
					var ratio1 : Number = _hzCount / FlashPoint.fixedDeltaTime;
					var ratio2 : Number = 1 - ratio1;
					_counter++;
					if (recycle && _particleRecycleHead)
					{
						var particle : GameObject = _particleRecycleHead.gameObject;
						_particleRecycleHead = _particleRecycleHead.nextParticle;
						particle.particleRecycler.next = null;
					}
					else particle = new GameObject(gameObject.name + "Particle" + _counter);
					particle.transform.x = posX * ratio2 + _prevPosX * ratio1;
					particle.transform.y = posY * ratio2 + _prevPosY * ratio1;
					particle.transform.rotation = rotation * ratio2 + _prevRotation * ratio1;
					
					
					if (maxParticleCount != uint.MAX_VALUE)
					{
						if (particle.particleHandler)
						{
							var handler : ParticleHandler = particle.particleHandler;
							handler.awake();
						}
						else handler = particle.addComponent(ParticleHandler) as ParticleHandler;
						handler._generator = this;
						handler._next = _latestParticle;
						if(_latestParticle) _latestParticle._prev = handler;
						_latestParticle = handler;
					}
					else if (particle.particleHandler) particle.removeComponent(particle.particleHandler);
					
					if (radius > 0)
					{
						var col : CircleCollider = particle.circleCollider || particle.addComponent(CircleCollider) as CircleCollider;
						col.radius = radius;
					}
					else if (particle.circleCollider) particle.removeComponent(particle.circleCollider);
					
					if (velocity || randomVelocity || mass || inertia)
					{
						var body : Rigidbody = particle.rigidbody || particle.addComponent(Rigidbody) as Rigidbody;
						var vx : Number = 0;
						var vy : Number = 0;
						if (velocity)
						{
							vx = velocity.x * ratio2 + _prevVelocityX * ratio1;
							vy = velocity.y * ratio2 + _prevVelocityY * ratio1;
						}
						if (randomVelocity)
						{
							vx += (_random = ((1 + (_random * 12414)) % 43231)) * 0.0000462630982 * randomVelocity.x - randomVelocity.x;
							vy += (_random = ((1 + (_random * 12414)) % 43231)) * 0.0000462630982 * randomVelocity.y - randomVelocity.y;
						}
						if (velocity || randomVelocity)
						{
							if (affectedByGravity)
							{
								vx += PowerGrid.gravityX * ratio1 * FlashPoint.fixedInterval;
								vy += PowerGrid.gravityY * ratio1 * FlashPoint.fixedInterval;
							}
							else body.affectedByGravity = false;
							body.velocity = new Point(vx, vy);
						}
						particle.sendAfter("RigidbodyInterpolator_setPrevious", "start", particle.transform.x , particle.transform.y, particle.transform.rotation);
						particle.transform.x += body.velocity.x * ratio1 * FlashPoint.fixedInterval;
						particle.transform.y += body.velocity.y * ratio1 * FlashPoint.fixedInterval;
						particle.sendBefore("RigidbodyInterpolator_setNext", "update", particle.transform.x, particle.transform.y, particle.transform.rotation);
						if (mass) body.mass = mass;
						else body.mass = 1;
						if (inertia) body.inertia = inertia;
						else body.inertia = 1;
					}
					else if (particle.rigidbody) particle.removeComponent(particle.rigidbody);
					
					if (graphicsName)
					{
						if (particle.renderer)
						{
							var renderer : Renderer = particle.renderer;
							renderer.sendToFront();
						}
						else renderer = particle.addComponent(Renderer) as Renderer;
						
						renderer.priority = graphicsPriority;
						
						if (isAnimation)
						{
							var animation : Animation = particle.animation || particle.addComponent(Animation) as Animation;
							animation.gotoAndPlay(0, graphicsName);
						}
						else
						{
							if (particle.animation) particle.removeComponent(particle.animation);
							renderer.setBitmapByName(graphicsName);
						}
					}
					else if (particle.renderer)
					{
						if (particle.animation) particle.removeComponent(particle.animation);
						particle.removeComponent(particle.renderer);
					}
					
					if (recycle)
					{
						if (particle.particleRecycler)
						{
							if (particle.circleCollider)
							{
								col = particle.circleCollider as CircleCollider;
								col.enable();
								col.material = PhysicMaterial.DEFAULT_MATERIAL;
								col.layers = 1;
							}
							if (particle.boxCollider)
							{
								(particle.boxCollider as BoxCollider).enable();
							}
							if (particle.triangleCollider)
							{
								(particle.triangleCollider as TriangleCollider).enable();
							}
							if (particle.rigidbody)
							{
								body = particle.rigidbody as Rigidbody;
								body.enable();
								body.freezeRotation = false;
								body.vanDerWaals = 0;
								body.angularDrag = 0;
								body.angularVelocity = 0;
							}
							if (sendMessage("onRecycle", particle)) return;
							continue;
						}
						else
						{
							particle.addListener("recycleParticle", addParticleToPool, true);
							particle.addDynamic("particleRecycler", { nextParticle : null } );
						}
					}
					if (sendMessage("onEmit", particle)) return;
				}
			}
			if (velocity)
			{
				_prevVelocityX = velocity.x;
				_prevVelocityY = velocity.y;
			}
			_prevPosX = posX;
			_prevPosY = posY;
			_prevRotation = rotation;
		}
		private function addParticleToPool(particle : GameObject) : void
		{
			if (isDestroyed)
			{
				particle.destroy();
				return;
			}
			if (particle.renderer)
			{
				(particle.renderer as Renderer).bitmapData = null;
				(particle.renderer as Renderer).updateBitmap = true;
			}
			if (particle.animation) particle.animation.stop();
			if (particle.boneAnimation) particle.boneAnimation.stop();
			if (particle.audio) particle.audio.stop();
			if (particle.circleCollider)
			{
				particle.circleCollider.disable();
			}
			if (particle.boxCollider)
			{
				particle.boxCollider.disable();
			}
			if (particle.triangleCollider)
			{
				particle.triangleCollider.disable();
			}
			if (particle.rigidbody)
			{
				particle.rigidbody.disable();
			}
			
			particle.particleRecycler.nextParticle = _particleRecycleHead;
			_particleRecycleHead = particle.particleRecycler;
			
		}
		/** @private **/
		public function onDestroy() : Boolean
		{
			velocity = randomVelocity = null;
			graphicsName = null;
			_latestParticle = null;
			if (_particleRecycleHead)
			{
				do
				{
					_particleRecycleHead.gameObject.destroy();
				}
				while ((_particleRecycleHead = _particleRecycleHead.nextParticle));
			}
			return false;
		}
	}
}