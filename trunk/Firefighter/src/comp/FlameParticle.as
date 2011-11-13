package comp 
{
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
		private var _body : Rigidbody;
		
		public var extinguished : Boolean = false;
		public var fluctuation : Number = 30;
		public var upDraft : Number = 10;
		private var _rotationOffset : Number = Math.random() * 360;
		internal var source : Fire = null;
		
		public function awake() : void
		{
			requireComponent(RigidbodyInterpolator);
			_body = gameObject.rigidbody;
			_body.affectedByGravity = false;
			//_body.vanDerWaals = 2200;
			//_body.freezeRotation = true;
			_body.drag = 0.01;
			var collider : Collider = (gameObject.circleCollider || gameObject.boxCollider) as Collider;
			collider.material = new PhysicMaterial(0.9, 0.9);
			collider.layers = 2;
			//(gameObject.renderer as Renderer).offset = new Matrix(0.5, 0, 0, 0.5, 0, 0);
		}
		public function fixedUpdate() : void
		{
			var random : Point = new Point(Math.random() * fluctuation - fluctuation * 0.5, Math.random() * fluctuation - fluctuation * 0.5 - upDraft);
			_body.addForce(random, ForceMode.ACCELLERATION);
			gameObject.transform.rotateTowards(gameObject.transform.position.add(_body.velocity), _rotationOffset);
			//gameObject.circleCollider.radius *= 0.95;
			//gameObject.transform.scale += (Math.random() * 3 - gameObject.transform.scale) * 0.25;
		}
		public function extinguish() : void
		{
			var frame : uint = gameObject.animation.playhead;
			source.heat -= 80 - gameObject.animation.playhead;
			gameObject.animation.gotoAndPlay(frame *  0.3, "SmokeAnimation");
			extinguished = true;
		}
	}

}