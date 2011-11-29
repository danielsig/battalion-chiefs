package comp.human 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.flashpoint.comp.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class CivilianController extends Component implements IExclusiveComponent 
	{
		
		public static function createCivilian(x : Number = 0, y : Number = 0) : GameObject
		{
			var civ : GameObject = new GameObject("human", CivilianController);
			civ.transform.x = x;
			civ.transform.y = y;
			return civ;
		}
		
		private var _tr : Transform;
		
		public function awake() : void 
		{
			//BODY
			
			HumanBodyFactory.createCivilian(gameObject);
			
			//COMPONENTS
			_tr = gameObject.transform;
			requireComponent(Audio);
		}
		public function fixedUpdate() : void 
		{
			//sendMessage("HumanBody_goLeft");
		}
	}

}