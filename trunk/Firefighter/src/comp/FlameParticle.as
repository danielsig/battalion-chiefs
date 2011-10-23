package comp 
{
	import com.battalion.flashpoint.core.*;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class FlameParticle extends Component implements IExclusiveComponent 
	{
		private var _body : Rigidbody;
		
		public var fluctuation : Number = 1;
		public var upDraft : Number = 1;
		
		public function awake() : void
		{
			_body = requireComponent(Rigidbody) as Rigidbody;
			_body.affectedByGravity = false;
			_body.vanDerWaals = 0.5;
			//_body.freezeRotation = true;
			_body.drag = 0.2;
			var collider : Collider = (gameObject.circleCollider || gameObject.boxCollider) as Collider;
			collider.material = new PhysicMaterial(0, 0.95);
			_body.mass = 0.1;
		}
		public function fixedUpdate() : void
		{
			var random : Point = new Point(Math.random() * fluctuation - fluctuation * 0.5, Math.random() * fluctuation - fluctuation * 0.5 - upDraft);
			_body.addForce(random, ForceMode.ACCELLERATION);
			gameObject.transform.rotateTowards(gameObject.transform.position.add(_body.velocity));
			//gameObject.transform.scale += (Math.random() * 3 - gameObject.transform.scale) * 0.25;
		}
	}

}