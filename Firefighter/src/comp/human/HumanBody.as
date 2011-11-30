package comp.human 
{
	import com.battalion.flashpoint.comp.*;
	import com.battalion.flashpoint.core.*;
	import comp.objects.LeftStairs;
	import comp.particles.Heat;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class HumanBody extends Component implements IExclusiveComponent
	{
		
		public static const BODY_HEIGHT : Number = 140;
		public static const HEAD_HEIGHT : Number = 20;
		public static const ARM_LENGTH : Number = 28;
		
		public static const TORSO_HALF_HEIGHT : Number = ((BODY_HEIGHT * 0.5) - HEAD_HEIGHT) * 0.5;
		public static const LEG_HALF_HEIGHT : Number = BODY_HEIGHT * 0.25;
		public static const SHOULDER_HEIGHT : Number = 12-TORSO_HALF_HEIGHT;
		
		private static var _initializer : Boolean = defineAnimations();
		
		private static function defineAnimations() : Boolean
		{			
			var t : Number = -TORSO_HALF_HEIGHT;
			var c : Number = LEG_HALF_HEIGHT;
			var s : Number = SHOULDER_HEIGHT;
			var a : Number = ARM_LENGTH;
			var h : Number = 15;
			
			BoneAnimation.define("humanIdle1", 2,
				{
					torsoY:[ -TORSO_HALF_HEIGHT],
					torsoA:[ 0],
					
					leftLegA:[ 15],
					rightLegA:[ -23],
					leftLegY:[h],
					rightLegY:[h],
					
					leftCalfA: [5],
					rightCalfA:[7],
					leftCalfY:[c],
					rightCalfY:[c],
					
					leftFootA:[-21],
					rightFootA:[ 15],
					leftFootY:[c],
					rightFootY:[c],
					
					leftArmA:[-12],
					rightArmA:[ 30],
					leftArmY:[s],
					rightArmY:[s],
					
					leftForearmA: [ -20],
					rightForearmA:[ -40],
					leftForearmY:[a],
					rightForearmY:[a]
				}
			);
			
			BoneAnimation.define("humanIdle2", 2,
				{
					torsoY:[ -TORSO_HALF_HEIGHT],
					torsoA:[ 0],
					
					leftLegA:[-23],
					rightLegA:[15],
					leftLegY:[h],
					rightLegY:[h],
					
					leftCalfA: [7],
					rightCalfA:[5],
					leftCalfY:[c],
					rightCalfY:[c],
					
					leftFootA:[15],
					rightFootA:[-21],
					leftFootY:[c],
					rightFootY:[c],
					
					leftArmA:[30],
					rightArmA:[-12],
					leftArmY:[s],
					rightArmY:[s],
					
					leftForearmA: [ -40],
					rightForearmA:[ -20],
					leftForearmY:[a],
					rightForearmY:[a]
				}
			);
			
			var ta : Number = 8;
			
			var leg1 : Number = -26;
			var leg2 : Number = -55;
			var leg3 : Number = -20;
			var leg4 : Number = 24;
			var leg5 : Number = 28;
			var leg6 : Number = 7;
			
			var c1 : Number = 85;
			var c2 : Number = 15;
			var c3 : Number = -6;
			var c4 : Number = -3;
			var c5 : Number = 50;
			var c6 : Number = 70;
			
			var f1 : Number = -20;
			var f2 : Number = -20;
			var f3 : Number = 10;
			var f4 : Number = -20;
			var f5 : Number = 40;
			var f6 : Number = 10;
			
			var a1 : Number = 20;
			var a2 : Number = 50;
			var a3 : Number = 30;
			var a4 : Number = 10;
			var a5 : Number = -30;
			var a6 : Number = -10;
			
			BoneAnimation.define("humanWalk", 9,
				{
					torsoY:[ t, t, t, t, t, t, t],
					torsoA:[ ta, ta, ta, ta, ta, ta, ta],
					
					leftLegA:[ leg1, leg2, leg3, leg4, leg5, leg6, leg1],
					rightLegA:[ leg4, leg5, leg6, leg1, leg2, leg3, leg4],
					leftLegY:[h, h, h, h, h, h, h],
					rightLegY:[h, h, h, h, h, h, h],
					
					leftCalfA: [ c1, c2, c3, c4, c5, c6, c1],
					rightCalfA:[ c4, c5, c6, c1, c2, c3, c4],
					leftCalfY:[c, c, c, c, c, c, c],
					rightCalfY:[c, c, c, c, c, c, c],
					
					leftFootA: [ f1, f2, f3, f4, f5, f6, f1],
					rightFootA:[ f4, f5, f6, f1, f2, f3, f4],
					leftFootY:[c, c, c, c, c, c, c],
					rightFootY:[c, c, c, c, c, c, c],
					
					leftArmA: [ a1, a2, a3, a4, a5, a6, a1],
					rightArmA:[ a4, a5, a6, a1, a2, a3, a4],
					leftArmY:[s, s, s, s, s, s, s],
					rightArmY:[s, s, s, s, s, s, s],
					
					leftForearmA: [ -60, -60, -60, -60, -60, -60, -60],
					rightForearmA:[ -60, -60, -60, -60, -60, -60, -60],
					leftForearmY:[a, a, a, a, a, a, a],
					rightForearmY:[a, a, a, a, a, a, a]
				}
			);
			
			Audio.load("test", "assets/sound/sounds.mp3~3199-3306~");
			Audio.load("test2", "assets/sound/sounds.mp3~3552-3677~");
			BoneAnimation.addLabel("humanWalk", "Audio_play", 4, "test", 1);
			BoneAnimation.addLabel("humanWalk", "Audio_play", 1, "test2", 1);
			
			
			ta = 16;
			
			//weight
			var t1 : Number = t;
			var t2 : Number = t-7;
			var t3 : Number = t+2;
			var t4 : Number = t;
			var t5 : Number = t-7;
			var t6 : Number = t+2;
			
			var w1 : Number = 5;
			var w2 : Number = 2;
			var w3 : Number = 0;
			var w4 : Number = 5;
			var w5 : Number = 2;
			var w6 : Number = 0;
			
			leg1 = -40;
			leg2 = -90;
			leg3 = -30;
			leg4 = 25;
			leg5 = 35;
			leg6 = 10;
			
			c1 = 110;
			c2 = 70;
			c3 = -8;
			c4 = -4;
			c5 = 75;
			c6 = 100;
			
			f1 = 40;
			f2 = -20;
			f3 = 10;
			f4 = -20;
			f5 = 40;
			f6 = 10;
			
			a1 *= 2;
			a2 *= 2;
			a3 *= 2;
			a4 *= 2;
			a5 *= 2;
			a6 *= 2;
			
			var hr : Number = 2.5;//head roll
			
			BoneAnimation.define("humanRun", 12,
				{
					torsoY:[ t1, t2, t3, t4, t5, t6, t1],
					torsoA:[ ta, ta, ta, ta, ta, ta, ta],
					headY:[ t+w1, t+w2, t+w3, t+w4, t+w5, t+w6, t+w1],
					headA:[w1*hr, w2*hr, w3*hr, w4*hr, w5*hr, w6*hr, w1*hr],
					
					leftLegA:[ leg1, leg2, leg3, leg4, leg5, leg6, leg1],
					rightLegA:[ leg4, leg5, leg6, leg1, leg2, leg3, leg4],
					leftLegY:[h, h, h, h, h, h, h],
					rightLegY:[h, h, h, h, h, h, h],
					
					leftCalfA: [ c1, c2, c3, c4, c5, c6, c1],
					rightCalfA:[ c4, c5, c6, c1, c2, c3, c4],
					leftCalfY:[c, c, c, c, c, c, c],
					rightCalfY:[c, c, c, c, c, c, c],
					
					leftFootA: [ f1, f2, f3, f4, f5, f6, f1],
					rightFootA:[ f4, f5, f6, f1, f2, f3, f4],
					leftFootY:[c, c, c, c, c, c, c],
					rightFootY:[c, c, c, c, c, c, c],
					
					leftArmA: [ a1, a2, a3, a4, a5, a6, a1],
					rightArmA:[ a4, a5, a6, a1, a2, a3, a4],
					leftArmY:[s+w1, s+w2, s+w3, s+w4, s+w5, s+w6, s+w1],
					rightArmY:[s+w1, s+w2, s+w3, s+w4, s+w5, s+w6, s+w1],
					
					leftForearmA: [ -90, -90, -90, -90, -90, -90, -90],
					rightForearmA:[ -90, -90, -90, -90, -90, -90, -90],
					leftForearmY:[a, a, a, a, a, a, a],
					rightForearmY:[a, a, a, a, a, a, a]
				}
			);
			
			BoneAnimation.addLabel("humanRun", "Audio_play", 4, "test", 1);
			BoneAnimation.addLabel("humanRun", "Audio_play", 1, "test2", 1);
			
			ta = 10;
			t = -TORSO_HALF_HEIGHT;
			
			BoneAnimation.define("humanJump", 7,
				{
					torsoY:[ t, t],
					torsoA:[ 0, ta],
					headY:[ t, t],
					headA:[0, 0,],
					
					leftLegA:[ -20, -60-ta],
					rightLegA:[ 20, 10-ta],
					leftLegY:[h, h],
					rightLegY:[h, h],
					
					leftCalfA: [ 10, 100],
					rightCalfA:[ 0, 20],
					leftCalfY:[c, c],
					rightCalfY:[c, c],
					
					leftFootA: [ 0, 20],
					rightFootA:[ -20, 40],
					leftFootY:[c, c],
					rightFootY:[c, c],
					
					leftArmA:[-21, -50],
					rightArmA:[ 15, 60],
					leftArmY:[s, s],
					rightArmY:[s, s],
					
					leftForearmA: [ -20, -80],
					rightForearmA:[ -40, -40],
					leftForearmY:[a, a],
					rightForearmY:[a, a]
				}
			);
			
			Audio.load("landing", "assets/sound/sounds.mp3~8986-9350~");
			
			BoneAnimation.define("humanFall", 4,
				{
					torsoY:[ t, t],
					torsoA:[ ta, ta],
					headY:[ t, t],
					headA:[0, 0,],
					
					leftLegA:[ -60-ta, -20],
					rightLegA:[ 10-ta, 10],
					leftLegY:[h, h],
					rightLegY:[h, h],
					
					leftCalfA: [ 100, 5],
					rightCalfA:[ 20, 0],
					leftCalfY:[c, c],
					rightCalfY:[c, c],
					
					leftFootA: [ 20, 40],
					rightFootA:[ 40, 30],
					leftFootY:[c, c],
					rightFootY:[c, c],
					
					leftArmA:[-50, -60],
					rightArmA:[ 60, 100],
					leftArmY:[s, s],
					rightArmY:[s, s],
					
					leftForearmA: [ -80, -90],
					rightForearmA:[ -40, -50],
					leftForearmY:[a, a],
					rightForearmY:[a, a]
				}
			);
			ta = 20;
			BoneAnimation.define("humanLeap", 8,
				{
					torsoY:[ t, t],
					torsoA:[ 0, ta],
					headY:[ t, t],
					headA:[0, 0,],
					
					leftLegA:[ -20, 40-ta],
					rightLegA:[ 20, -90-ta],
					leftLegY:[h, h],
					rightLegY:[h, h],
					
					leftCalfA: [ 10, 60],
					rightCalfA:[ 0, 70],
					leftCalfY:[c, c],
					rightCalfY:[c, c],
					
					leftArmA:[-21, -60],
					rightArmA:[ 15, 80],
					leftArmY:[s, s],
					rightArmY:[s, s],
					
					leftForearmA: [ -20, -90],
					rightForearmA:[ -40, -70],
					leftForearmY:[a, a],
					rightForearmY:[a, a]
				}
			);
			return true;
		}
		
		public var speed : Number = 100;
		public var backSpeed : Number = 60;
		public var runSpeed : Number = 180;
		public var jumpSpeed : Number = 220;
		
		private var _animation : BoneAnimation = null;
		private var _rigidbody : Rigidbody = null;
		private var _tr : Transform = null;
		
		private var _facingLeft : Boolean = false;
		private var _running : Boolean = false;
		private var _jumping : Boolean = false;
		private var _movement : int = 0;
		private var _verticalMovement : int = 0;
		
		private var _inAir : Boolean = true;
		private var _forceGrounded : Boolean = false;
		
		public function get horizontalDirection() : int
		{
			return _movement;
		}
		public function get verticalDirection() : int
		{
			return _verticalMovement;
		}
		public function get running() : Boolean
		{
			return _running;
		}
		public function set running(value : Boolean) : void
		{
			_running = value;
		}
		public function get currentSpeed() : Number
		{
			return _movement ? (_running ? runSpeed : speed) : 0;
		}
		public function get currentVelocity() : Number
		{
			return _movement * (_running ? runSpeed : speed);
		}
		
		public function faceRight() : void
		{
			_facingLeft = false;
		}
		public function faceLeft() : void
		{
			_facingLeft = true;
		}
		
		public function startRunning() : void
		{
			_running = true;
		}
		public function stopRunning() : void
		{
			_running = false;
		}
		public function goLeft() : void
		{
			_movement = -1;
		}
		public function goRight() : void
		{
			_movement = 1;
		}
		public function goUp() : void
		{
			_verticalMovement = -1;
		}
		public function goUpStairs() : void
		{
			_verticalMovement = -2;
		}
		
		public function goDownStairs() : void
		{
			_verticalMovement = 2;
		}
		
		public function jump() : void
		{
			_jumping = true;
		}
		
		public function get grounded() : Boolean
		{
			return !_inAir;
		}
		public function set grounded(value : Boolean) : void
		{
			_forceGrounded = true;
		}
		
		public function fixedUpdate() : void 
		{
			gameObject.torso.audio.volume = 1;
			_rigidbody.affectedByGravity = true;
			var points : Vector.<ContactPoint> = _rigidbody.touchingInDirection(new Point(0, 1), 0.2);
			/*for each(var point : ContactPoint in points)
			{
				if(point.otherCollider) point.otherCollider.sendMessage("onHumanHit", this);
			}*/
			if (points && points.length || _forceGrounded)
			{
				if (_forceGrounded)
				{
					var v : Point = _rigidbody.velocity;
					v.x *= 0.5;
					v.y *= 0.5;
					_rigidbody.velocity = v;
				}
				if (_inAir)
				{
					//landing
					_inAir = false;
					sendMessage("Audio_play", "landing", 1);
				}
				else
				{
					var leftFootAhead : Boolean = _animation.currentName == "humanidle2";
					if (_movement > 0)
					{
						gameObject.torso.audio.volume = 0.5;
						_rigidbody.addForceX((_facingLeft ? backSpeed : (_running ? runSpeed : speed)), ForceMode.ACCELLERATION);
						_tr.scaleX = 1;
						_animation.reversed = _facingLeft;
						_animation.transitionTime = 300;
						var correctAnimation : String = _running && !_facingLeft ? "humanRun" : "humanWalk";
						var correctFrame : Number = _animation.currentName == "humanRun" || _animation.currentName == "humanWalk" ? _animation.playhead : (_animation.currentName == "humanIdle2" ? 2.1 : 5.1);
						if(_animation.currentName != correctAnimation || !_animation.playing) _animation.gotoAndPlay(correctFrame, correctAnimation);
					}
					else if (_movement < 0)
					{
						gameObject.torso.audio.volume = 0.5;
						_rigidbody.addForceX(-(!_facingLeft ? backSpeed : (_running ? runSpeed : speed)), ForceMode.ACCELLERATION);
						_tr.scaleX = -1;
						_animation.reversed = !_facingLeft;
						_animation.transitionTime = 300;
						correctAnimation = _running && _facingLeft ? "humanRun" : "humanWalk";
						correctFrame = _animation.currentName == "humanRun" || _animation.currentName == "humanWalk" ? _animation.playhead : (_animation.currentName == "humanIdle2" ? 2.1 : 5.1);
						if(_animation.currentName != correctAnimation || !_animation.playing) _animation.gotoAndPlay(correctFrame, correctAnimation);
					}
					else
					{
						//grounded and not moving, but the human is not in an idle pose
						if (_animation.currentName != "humanIdle1" && _animation.currentName != "humanIdle2")
						{
							_animation.transitionTime = 200;
							if (leftFootAhead || (_animation.playhead > 6.5 || _animation.playhead < 3.5)) _animation.play("humanIdle2");
							else _animation.play("humanIdle1");
							gameObject.torso.head.transform.y = -TORSO_HALF_HEIGHT;
							//gameObject.torso.sendMessage("Audio_stop");
						}
					}
				}
				if (_jumping)
				{
					if (_forceGrounded) _tr.y -= 6;
					_rigidbody.addForce(new Point(0, -jumpSpeed), ForceMode.ACCELLERATION);
					_animation.transitionTime = 50;
					_animation.play((_rigidbody.velocity.x > 20 || _rigidbody.velocity.x < -20) && !_animation.reversed ? "humanLeap" : "humanJump", 1);
					_inAir = true;
				}
			}
			else
			{
				_inAir = true;
				if (_rigidbody.velocity.y > 0 && _animation.currentName != "humanFall" && _animation.currentName != "humanLeap")
				{
					_animation.play("humanFall", 1);
				}
			}
			if (!_jumping)
			{
				if (_facingLeft)
				{
					if (_tr.scaleX > 0)
					{
						_animation.transitionTime = 0;
						if (_animation.currentName == "humanIdle1")
						{
							_animation.currentName = "humanIdle2";
						}
						else if(_animation.currentName == "humanIdle2")
						{
							_animation.currentName = "humanIdle1";
						}
						else if(_animation.currentName == "humanRun" || _animation.currentName == "humanWalk")
						{
							_animation.playhead += 3;
						}
					}
					_tr.scaleX = -1;
				}
				else
				{
					if (_tr.scaleX < 0)
					{
						_animation.transitionTime = 0;
						if (_animation.currentName == "humanIdle1")
						{
							_animation.currentName = "humanIdle2";
						}
						else if(_animation.currentName == "humanIdle2")
						{
							_animation.currentName = "humanIdle1";
						}
						else if(_animation.currentName == "humanRun" || _animation.currentName == "humanWalk")
						{
							_animation.playhead += 3;
						}
					}
					_tr.scaleX = 1;
				}
			}
			_forceGrounded = false;
			sendBefore("beforeNextFixedUpdate", "fixedUpdate");
		}
		public function beforeNextFixedUpdate() : void 
		{
			_jumping = false;
			_movement = _verticalMovement = 0;
		}
		
		public function defineAppearance(
			torso : String = null, head : String = null,
			leftLeg : String = null, rightLeg : String = null,
			leftCalf : String = null, rightCalf : String = null,
			leftFoot : String = null, rightFoot : String = null,
			leftArm : String = null, rightArm : String = null,
			leftForearm : String = null, rightForearm : String = null,
			leftHand : String = null, rightHand : String = null,
			legX : Number = 0, legY : Number = 0,
			calfX : Number = 0, calfY : Number = 0,
			footX : Number = 0, footY : Number = 0,
			armX : Number = 0, armY : Number = 0,
			forearmX : Number = 0, forearmY : Number = 0,
			handX : Number = 0, handY : Number = 0
		) : void
		{
			
			var torsoObj : GameObject = gameObject.torso;
			var left : GameObject = torsoObj.leftLeg;
			var right : GameObject = torsoObj.rightLeg;
			
			//left is behind, right is on front
			
			if (torso) ((torsoObj.renderer || torsoObj.addComponent(Renderer)) as Renderer).setBitmapByName(torso);

			
			if (head)
			{
				((torsoObj.head.renderer || torsoObj.head.addComponent(Renderer)) as Renderer).setBitmapByName(head);
				torsoObj.head.renderer.offset = new Matrix(1, 0, 0, 1, 0, -HEAD_HEIGHT * 0.5);
				if(torsoObj.renderer) torsoObj.head.renderer.putInFrontOf(torsoObj.renderer);
			}
			if (leftLeg)
			{
				((left.renderer || left.addComponent(Renderer)) as Renderer).setBitmapByName(leftLeg);
				left.renderer.offset = new Matrix(1, 0, 0, 1, legX, legY);
				if(torsoObj.renderer) left.renderer.putBehind(torsoObj.renderer);
			}
			if (rightLeg)
			{
				((right.renderer || right.addComponent(Renderer)) as Renderer).setBitmapByName(rightLeg);
				right.renderer.offset = new Matrix(1, 0, 0, 1, legX, legY);
				if(torsoObj.head.renderer) right.renderer.putInFrontOf(torsoObj.head.renderer);
			}
			
			left = left.leftCalf;
			right = right.rightCalf;
			
			if (leftCalf)
			{
				((left.renderer || left.addComponent(Renderer)) as Renderer).setBitmapByName(leftCalf);
				left.renderer.offset = new Matrix(1, 0, 0, 1, calfX, calfY);
				if(left.parent.renderer) left.renderer.putInFrontOf(left.parent.renderer);
			}
			
			if (rightCalf)
			{
				((right.renderer || right.addComponent(Renderer)) as Renderer).setBitmapByName(rightCalf);
				right.renderer.offset = new Matrix(1, 0, 0, 1, calfX, calfY);
				if(right.parent.renderer) right.renderer.putInFrontOf(right.parent.renderer);
			}
			
			
			left = left.leftFoot;
			right = right.rightFoot;
			
			if (leftFoot)
			{
				((left.renderer || left.addComponent(Renderer)) as Renderer).setBitmapByName(leftFoot);
				left.renderer.offset = new Matrix(1, 0, 0, 1, footX, footY);
				if(left.parent.renderer) left.renderer.putInFrontOf(left.parent.renderer);
			}
			
			if (rightFoot)
			{
				((right.renderer || right.addComponent(Renderer)) as Renderer).setBitmapByName(rightFoot);
				right.renderer.offset = new Matrix(1, 0, 0, 1, footX, footY);
				if(right.parent.renderer) right.renderer.putInFrontOf(right.parent.renderer);
			}
			
			var hindMostRenderer : Renderer = torsoObj.leftLeg.renderer || left.parent.renderer || left.renderer || torsoObj.renderer;
			var frontMostRenderer : Renderer = right.renderer || right.parent.renderer || right.parent.parent.renderer || torsoObj.head.renderer || torsoObj.renderer;
			
			left = torsoObj.leftArm;
			right = torsoObj.rightArm;
			
			if (leftArm)
			{
				((left.renderer || left.addComponent(Renderer)) as Renderer).setBitmapByName(leftArm);
				left.renderer.offset = new Matrix(1, 0, 0, 1, armX, armY);
				if (hindMostRenderer) left.renderer.putBehind(hindMostRenderer);
			}
			if (rightArm)
			{
				((right.renderer || right.addComponent(Renderer)) as Renderer).setBitmapByName(rightArm);
				right.renderer.offset = new Matrix(1, 0, 0, 1, armX, armY);
				if (frontMostRenderer) right.renderer.putBehind(frontMostRenderer);
			}
			
			left = left.leftForearm;
			right = right.rightForearm;
			
			if (leftForearm)
			{
				((left.renderer || left.addComponent(Renderer)) as Renderer).setBitmapByName(leftForearm);
				left.renderer.offset = new Matrix(1, 0, 0, 1, forearmX, forearmY);
				if(left.parent.renderer) left.renderer.putInFrontOf(left.parent.renderer);
			}
			if (rightForearm)
			{
				((right.renderer || right.addComponent(Renderer)) as Renderer).setBitmapByName(rightForearm);
				right.renderer.offset = new Matrix(1, 0, 0, 1, forearmX, forearmY);
				if(right.parent.renderer) right.renderer.putInFrontOf(right.parent.renderer);
			}
			
			left = left.leftHand;
			right = right.rightHand;
			
			if (leftHand)
			{
				((left.renderer || left.addComponent(Renderer)) as Renderer).setBitmapByName(leftHand);
				left.renderer.offset = new Matrix(1, 0, 0, 1, handX, handY);
				if(left.parent.renderer) left.renderer.putInFrontOf(left.parent.renderer);
			}
			if (rightHand)
			{
				((right.renderer || right.addComponent(Renderer)) as Renderer).setBitmapByName(rightHand);
				right.renderer.offset = new Matrix(1, 0, 0, 1, handX, handY);
				if(right.parent.renderer) right.renderer.putInFrontOf(right.parent.renderer);
			}
		}
		
		public function awake() : void
		{
			var box : BoxCollider = requireComponent(BoxCollider) as BoxCollider;
			_rigidbody = requireComponent(Rigidbody) as Rigidbody;
			requireComponent(RigidbodyInterpolator);
			(requireComponent(Heat) as Heat).materialType = Heat.PLASTIC;
			_tr = gameObject.transform;
			
			//PHSYICS
			box.dimensions = new Point(62, 126);
			box.material = new PhysicMaterial(0.3, 0);
			box.layers = Layers.FIRE_VS_HUMANS | Layers.OBJECTS_VS_HUMANS | Layers.STAIRS;
			_rigidbody.mass = 100;
			_rigidbody.drag = 0;
			_rigidbody.freezeRotation = true;
			
			//TORSO
			var torso : GameObject = gameObject.torso as GameObject || new GameObject("torso", gameObject, BoneAnimation);
			torso.addComponent(Audio);
			
			//setting animation
			_animation = torso.boneAnimation;
			
			//HEAD
			var head : GameObject = torso.head as GameObject || new GameObject("head", torso);
			head.transform.y = -TORSO_HALF_HEIGHT;
			
			//LEFT LEG
			var left : GameObject = torso.leftLeg as GameObject || new GameObject("leftLeg", torso);
			
			//RIGHT LEG
			var right : GameObject = torso.rightLeg as GameObject || new GameObject("rightLeg", torso);
			
			//LEFT CALF
			left = left.leftCalf as GameObject || new GameObject("leftCalf", left);
			left.transform.y = LEG_HALF_HEIGHT;
			
			//RIGHT CALF
			right = right.rightCalf as GameObject || new GameObject("rightCalf", right);
			right.transform.y = LEG_HALF_HEIGHT;
			
			//LEFT FOOT
			left = left.leftFoot as GameObject || new GameObject("leftFoot", left);
			left.transform.y = LEG_HALF_HEIGHT;
			
			//RIGHT FOOT
			right = right.rightFoot as GameObject || new GameObject("rightFoot", right);
			right.transform.y = LEG_HALF_HEIGHT;
			
			
			//LEFT ARM
			left = torso.leftArm as GameObject || new GameObject("leftArm", torso);
			left.transform.y = SHOULDER_HEIGHT;
			
			//RIGHT ARM
			right = torso.rightArm as GameObject || new GameObject("rightArm", torso);
			right.transform.y = SHOULDER_HEIGHT;
			
			//LEFT FOREARM
			left = left.leftForearm as GameObject || new GameObject("leftForearm", left);
			left.transform.y = ARM_LENGTH;
			
			//RIGHT FOREARM
			right = right.rightForearm as GameObject || new GameObject("rightForearm", right);
			right.transform.y = ARM_LENGTH;
			
			//LEFT HAND
			left = left.leftHand as GameObject || new GameObject("leftHand", left);
			left.transform.y = ARM_LENGTH;
			
			//RIGHT HAND
			right = right.rightHand as GameObject || new GameObject("rightHand", right);
			right.transform.y = ARM_LENGTH;
			
			
			//STARTING IDLE ANIMATION
			_animation.play("humanIdle1");
		}
		
	}

}