package com.battalion.flashpoint.comp.misc 
{
	import com.battalion.flashpoint.core.Component;
	import com.battalion.flashpoint.core.IExclusiveComponent;
	import com.battalion.flashpoint.core.Transform;
	import flash.geom.Matrix;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Stalker extends Component implements IExclusiveComponent 
	{
		
		public var target : Transform = null;
		private var _transform : Transform = null;
		
		public function awake() : void
		{
			_transform = gameObject.transform;
		}
		
		public function update() : void
		{
			if (target)
			{
				var isKinimatic : Boolean = gameObject.beginMovement;
				
				if(isKinimatic) gameObject.beginMovement();
				var m : Matrix = target.globalMatrix;
				_transform.setMatrix(m.a, m.b, m.c, m.d, m.tx, m.ty);
				if(isKinimatic) gameObject.endMovement();
				/*
				_transform.matrix.a = target.globalMatrix.a;
				_transform.matrix.b = target.globalMatrix.b;
				_transform.matrix.c = target.globalMatrix.c;
				_transform.matrix.d = target.globalMatrix.d;
				_transform.x = target.globalMatrix.tx;
				_transform.y = target.globalMatrix.ty;
				*/
			}
		}
		
	}

}