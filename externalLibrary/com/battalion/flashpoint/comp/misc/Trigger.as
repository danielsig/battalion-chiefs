package com.battalion.flashpoint.comp.misc 
{
	import com.battalion.flashpoint.core.*;
	import com.battalion.*;
	import com.battalion.flashpoint.comp.*;
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final class Trigger extends Component
	{
		
		//public static var trigger_key;
		
		public var height : Number;
		public var width : Number;
		public var target : Transform;
		private var _activeTrigger : Boolean = true;
		//private var _atTrigger : Boolean = false;
		private var _onEnter : Boolean = false;
		private var _onStay : Boolean = false;
		private var _onLeave : Boolean = false;
		
		public function get onStay() : Boolean
		{
			return _onStay;
		}
		
		public static function addTrigger(object : GameObject, width : Number, height : Number, triggerTarget : Transform, particleTrigger : Boolean) : void
		{
			var trigger : Trigger = object.addComponent(Trigger) as Trigger;
			trigger.width = width;
			trigger.height = height;
			trigger.target = triggerTarget;
			
			if (particleTrigger)
			{
				object.addComponent(TriggerFire) as TriggerFire;
				//var fireParticles : ParticleGenerator = object.addComponent(ParticleGenerator) as ParticleGenerator;
				//fireParticles._particleGenerator
			}
		}
		
		public function fixedUpdate() : void
		{
			CONFIG::debug
			{
				if (!target) throw new Error("Target must be non-null.");
				if (width < 0) throw new Error ("Width must be greater then zero.");
				if (height < 0) throw new Error ("Height must be greater then zero.");
			}
			
			if (_activeTrigger)
			{
				var top : Number = gameObject.transform.y - ( height * 0.5);
				var bottom : Number = gameObject.transform.y + ( height * 0.5);
				var left : Number = gameObject.transform.x - ( width * 0.5);
				var right : Number = gameObject.transform.x + ( width * 0.5);
				
				var x : Number = target.x;
				var y : Number = target.y;
				
				if ( (x > left && x < right) && (y > top && y < bottom))
				{
					if (!_onEnter)
					{
						log("targetEnteringTrigger", target.gameObject, this);
						sendMessage("targetEnteringTrigger", target.gameObject, this);
						target.sendMessage("isEnteringTrigger", this);
						_onEnter = true;
					}
					_onStay = true;
					sendMessage("targetOnTrigger", target.gameObject, this);
					target.sendMessage("isOnTrigger", this);
					
				}	
				else if (_onEnter)
				{
					_onEnter = false;
					_onStay = false;
					
					log("targetLeftTrigger", target.gameObject, this);
					sendMessage("targetLeftTrigger", target.gameObject, this);
					target.sendMessage("hasLeftTrigger", this);
					
				}
				
			}
			_activeTrigger = true;
			
		}
		
	}
}