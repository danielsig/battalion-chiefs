package com.battalion 
{
	import flash.utils.Dictionary;
	/**
	 * A class for near audomatic syncing of properties
	 * @author Battalion Chiefs
	 */
	public final class SyncedProperty 
	{
		private var _subscribers : Object = { next:null}
		private var _value : *;
		/**
		 * Call this function in order to subscribe a property of an object to the value of this SyncedProperty
		 * @param	target, the object that contains the property that should be subscribed to this SyncedProperty
		 * @param	targetPropertyNameChain, the property chain of the target that should be synced, e.g. "position.x"
		 * @param	syncedPropertyNameChain, the property chain of the synced value that will assigned to the target property, e.g. "transform.matrix.tx"
		 */
		public function subscribe(target : *, targetPropertyNameChain : String, syncedPropertyNameChain : String = null) : *
		{
			var targetChain : Array = targetPropertyNameChain.split(".");
			var syncChain : Array = syncedPropertyNameChain ? syncedPropertyNameChain.split(".") : null;
			_subscribers.next = { target : target, targetChain : targetChain, syncChain : syncChain, targetChainString : targetPropertyNameChain, syncChainString : syncedPropertyNameChain, next : null };
			if (_value != undefined)
			{
				var targetProp : * = target;
				var len1 : uint = targetChain.length - 1;
				for (var i : uint = 0; i < len1; i++)
				{
					targetProp = targetProp[targetChain[i]];
				}
				var syncProp : * = _value;
				if (syncChain)
				{
					var len2 : uint = syncChain.length - 1;
					for (i = 0; i < len2; i++)
					{
						syncProp = syncProp[syncChain[i]];
					}
					targetProp[targetChain[len1]] = syncProp[syncChain[len2]];
					return syncProp[syncChain[len2]];
				}
				else targetProp[targetChain[len1]] = _value;
				
				return _value;
			}
			return null;
		}
		/**
		 * Call this function in order to cancel subscription of a property.
		 * The parameters you pass to this function call must match exactly the parameters of your subscribe function call.
		 * @param	target
		 * @param	targetPropertyNameChain
		 * @param	syncedPropertyNameChain
		 */
		public function unsubscribe(target : *, targetPropertyNameChain : String, syncedPropertyNameChain : String = null) : void
		{
			var current : Object = _subscribers;
			var prev : Object = _subscribers;
			while ((current = current.next))
			{
				if (current.target == target && targetPropertyNameChain == current.targetChainString && syncedPropertyNameChain == current.syncChainString)
				{
					prev.next = current.next;
					delete current.target;
					delete current.targetChain;
					delete current.syncChain;
					delete current.targetChainString;
					delete current.syncChainString;
					return;
					
				}
				prev = current;
			}
		}
		public function sync(value : *) : void
		{
			_value = value;
			var current : Object = _subscribers;
			while ((current = current.next))
			{
				var targetChain : Array = current.targetChain;
				var syncChain : Array = current.syncChain;
				var targetProp : * = current.target;
				
				var len1 : uint = targetChain.length - 1;
				for (var i : uint = 0; i < len1; i++)
				{
					targetProp = targetProp[targetChain[i]];
				}
				if (syncChain)
				{
					var syncProp : * = value;
					var len2 : uint = syncChain.length - 1;
					for (i = 0; i < len2; i++)
					{
						syncProp = syncProp[syncChain[i]];
					}
					targetProp[targetChain[len1]] = syncProp[syncChain[len2]];
				}
				else targetProp[targetChain[len1]] = value;
			}
		}
	}

}