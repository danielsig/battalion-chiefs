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
		private static var _flameMaterial : PhysicMaterial = new PhysicMaterial(0.9, 0.9);
		
		private var _body : Rigidbody;
		private var _col : CircleCollider;
		private var _rotationOffset : Number = Math.random() * 360;
		private var _tr : Transform;
		private var _counter : int = 0;
		
		public var extinguished : Boolean = false;
		public var fluctuation : Number = 30;
		public var upDraft : Number = 10;
		internal var source : Fire = null;
		
		public function awake() : void
		{
			_tr = gameObject.transform;
			requireComponent(RigidbodyInterpolator);
			_body = gameObject.rigidbody;
			_body.affectedByGravity = false;
			_body.drag = 0.01;
			
			_col = gameObject.circleCollider as CircleCollider;
			_col.material = _flameMaterial;
			_col.layers = 2;
		}
		public function fixedUpdate() : void
		{
			var random : Point = new Point(Math.random() * fluctuation - fluctuation * 0.5, Math.random() * fluctuation - fluctuation * 0.5 - upDraft);
			_body.addForce(random, ForceMode.ACCELLERATION);
			var rotation : Number =  _tr.rotation;
			_tr.rotateTowards(_tr.position.add(_body.velocity), _rotationOffset);
			_body.angularVelocity = _tr.rotation - rotation;
			if (_counter++ > 40 || !_counter)
			{
				_counter = -20;
				_col.radius *= 0.6;
			}
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