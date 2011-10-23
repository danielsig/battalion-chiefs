package com.battalion.flashpoint.core 
{
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class RigidbodyInterpolator extends Component implements IExclusiveComponent 
	{
		
		private var _prevX : Number;
		private var _prevY : Number;
		private var _prevA : Number;
		
		private var _nextX : Number;
		private var _nextY : Number;
		private var _nextA : Number;
		
		private var _transform : Transform;
		
		public function awake() : void
		{
			requireComponent(Rigidbody);
			_transform = _gameObject.transform;
		}
		public function start() : void
		{
			_prevX = _nextX = _transform.x;
			_prevY = _nextY = _transform.y;
			_prevA = _nextA = _transform.rotation;
		}
		
		public function update() : void
		{
			var nextRatio : Number = FlashPoint.frameInterpolationRatio;
			var prevRatio : Number = 1.0 - nextRatio;
			
			var angle : Number = (180 - ((180 - (_prevA * prevRatio + _nextA * nextRatio)) % 360)) * 0.0174532925;
			
			if(angle < 0.7854){
				if(angle < -1.571){
					if(angle < -2.3562) var cos : Number = 0.475 * angle * angle + angle * 2.9831 + 3.687;
					else cos = 1.2711 * angle + 0.0915 * angle * angle + 1.764;
				}else if(angle < -0.7854) cos = 0.676 * angle - 0.0921 * angle * angle + 1.302;
				else cos = -0.482 * angle * angle + 1;
			}else if(angle < 2.3562){
				if(angle < 1.5708) cos = -0.676 * angle - 0.0921 * angle * angle + 1.302
				else cos = -1.2711 * angle + 0.0915 * angle * angle + 1.764;
			}else cos = 0.475 * angle * angle + angle * -2.9831 + 3.687;
			
			if(angle < -1.57079632) angle += 4.71238899;
			else angle -= 1.57079632;
			
			if(angle < 0.7854){
				if(angle < -1.571){
					if(angle < -2.3562) var sin : Number = 0.475 * angle * angle + angle * 2.9831 + 3.687;
					else sin = 1.2711 * angle + 0.0915 * angle * angle + 1.764;
				}else if(angle < -0.7854) sin = 0.676 * angle - 0.0921 * angle * angle + 1.302;
				else sin = -0.482 * angle * angle + 1;
			}else if(angle < 2.3562){
				if(angle < 1.5708) sin = -0.676 * angle - 0.0921 * angle * angle + 1.302
				else sin = -1.2711 * angle + 0.0915 * angle * angle + 1.764;
			}else sin = 0.475 * angle * angle + angle * -2.9831 + 3.687;
			
			_transform.matrix.tx =			_prevX * prevRatio + _nextX * nextRatio;
			_transform.matrix.ty =			_prevY * prevRatio + _nextY * nextRatio;
			
			_transform.matrix.a = cos * _transform.scaleX - sin * _transform._shearYTan;
			_transform.matrix.b = sin * _transform.scaleX + cos * _transform._shearYTan;
			_transform.matrix.c = -sin * _transform.scaleY + cos * _transform._shearXTan;
			_transform.matrix.d = cos * _transform.scaleY + sin * _transform._shearXTan;
			
		}
		public function fixedUpdate() : void
		{
			var physics : Object = _gameObject._physicsComponents;
			_prevX = _nextX;
			_prevY = _nextY;
			_prevA = _nextA;
			_nextX = physics.body.x + Physics._offsetX;
			_nextY = physics.body.y + Physics._offsetY;
			_nextA = physics.body.a;
			if (_nextA - _prevA > 180) _prevA += 360;
			if (_nextA - _prevA < -180) _prevA -= 360;
		}
	}

}