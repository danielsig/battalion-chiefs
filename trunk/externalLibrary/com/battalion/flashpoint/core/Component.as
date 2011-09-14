package com.battalion.flashpoint.core 
{
	import flash.utils.getQualifiedClassName;
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public class Component 
	{
		
		internal var _gameObject : GameObject;
		
		CONFIG::debug
		{
			internal var _requiredBy : Vector.<Component> = new Vector.<Component>();
			internal var _require : Vector.<Component> = new Vector.<Component>();
			public static function get world() : GameObject
			{
				return GameObject.WORLD;
			}
		}
		CONFIG::release
		public static var world : GameObject;
		
		public final function get gameObject() : GameObject
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
			}
			return _gameObject;
		}
		public final function destroy() : void
		{
			CONFIG::debug
			{
				if (this is IConciseComponent) throw new Error(this + " implements the IConciseComponent interface. Do not delete concise components manually, they do that automatically.");
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
			}
			removeComponent(this);
		}
		internal final function destroyConcise(message : String) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
			}
			var messages : Object = _gameObject._messages;
			var f : Function = this[message] as Function;
			if (f != null)
			{
				var rcv : Vector.<Function> = messages[message];
				var index : int = rcv.lastIndexOf(f);
				if (index > -1)
				{
					if (index < rcv.length - 1)
					{
						rcv[index] = rcv.pop();
					}
					else
					{
						rcv.length--;
					}
				}
			}
			
			var instanceIndex : int = _gameObject._components.lastIndexOf(this);
			if (instanceIndex < _gameObject._components.length - 1)
			{
				_gameObject._components[instanceIndex] = _gameObject._components.pop();
			}
			else
			{
				_gameObject._components.length--;
			}
		}
		public final function addConcise(comp : Class, message : String) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null.");
			}
			_gameObject.addConcise(comp, message);
		}
		public final function addComponent(comp : Class) : Component
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null.");
			}
			return _gameObject.addComponent(comp);
		}
		public final function removeComponent(instance : Component) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (instance == null) throw new Error("Instance must be non null.");
				if (instance is IConciseComponent) throw new Error(instance + " implements the IConciseComponent interface. Do not remove concise components manually, they do it themselves automatically.");
			}
			_gameObject.removeComponent(instance);
		}
		public final function requireComponent(comp : Class) : Component
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null.");
				if (Util.isConcise(comp)) throw new Error(comp + " implements the IConciseComponent interface. A component may not require a concise component.");
			}
			var name : String = getQualifiedClassName(comp);
			name = name.slice(name.lastIndexOf("::") + 2);
			name = name.charAt(0).toLowerCase() + name.slice(1);
			if (_gameObject.hasOwnProperty(name))
			{
				var instance : Component = _gameObject[name];
			}
			else
			{
				instance = addComponent(comp);
			}
			CONFIG::debug
			{
				instance._requiredBy.push(this);
				_require.push(instance);
			}
			return instance;
		}
		public final function sendMessage(message : String, ...args) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
			}
			var msg : Object = _gameObject._messages;
			var receivers : Vector.<Function>;
			
			if (!msg.hasOwnProperty(message))
			{
				receivers = new Vector.<Function>();
				for each(var component : Component in _gameObject._components)
				{
					if (component.hasOwnProperty(message))
					{
						receivers.push(component[message]);
					}
				}
				msg[message] = receivers;
			}
			else
			{
				receivers = msg[message];
			}
			if (_gameObject._before.hasOwnProperty(message))
			{
				for each(var before : Array in _gameObject._before[message])
				{
					sendMessage.apply(this, before);
				}
				delete _gameObject._before[message];
			}
			for each(var receiver : Function in receivers)
			{
				receiver.apply(this, args);
			}
			if (_gameObject._after.hasOwnProperty(message))
			{
				msg = _gameObject._after[message];
				for(var after : String in msg)
				{
					if (after == "destroyConcise")
					{
						for each(var f : Function in msg[after])
						{
							f(message);
						}
					}
					else
					{
						sendMessage.apply(this, msg[after]);
					}
				}
				delete _gameObject._after[message]
			}
		}
		public final function sendAfter(message : String, target : String, ...args) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
				if (target == null) throw new Error("Target must be non null.");
			}
			args.unshift(message);
			if (!_gameObject._after.hasOwnProperty(target))
			{
				_gameObject._after[target] = { };
			}
			_gameObject._after[target][message] = args;
		}
		public final function sendBefore(message : String, target : String, ...args) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
				if (target == null) throw new Error("Target must be non null.");
			}

			args.unshift(message);
			if (!_gameObject._before.hasOwnProperty(target))
			{
				_gameObject._before[target] = { };
			}
			_gameObject._before[target][message] = args;
		}
		public final function chain(invoker : String, ...messages) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (invoker == null) throw new Error("Invoker must be non null.");
				if (!messages.length) throw new Error("Expecting at least one message as parameter.");
				for each(var message : String in messages)
				{
					if (messages == null) throw new Error("Each message in the sequence must be non null.");
				}
			}
			sendAfter(messages[0], invoker);
			var c : int = messages.length;
			while(--c)
			{
				sendAfter(messages[c], messages[c-1]);
			}
		}
		public final function sequence(...messages) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (!messages.length) throw new Error("Expecting at least one message as parameter.");
				for each(var message : String in messages)
				{
					if (messages == null) throw new Error("Each message in the sequence must be non null.");
				}
			}

			var c : int = messages.length;
			while(--c)
			{
				sendAfter(messages[c], messages[c-1]);
			}
			sendMessage(messages[0]);
		}
		public function toString() : String
		{
			var name : String = getQualifiedClassName(this);
			name = name.slice(name.lastIndexOf("::") + 2);
			name = name.charAt(0).toLowerCase() + name.slice(1);
			return _gameObject ? (_gameObject + "." + name) : ("null." + name);
		}
		public function log(...args) : void
		{
			CONFIG::debug
			{
				var name : String = getQualifiedClassName(this);
				name = name.slice(name.lastIndexOf("::") + 2);
				name = name.charAt(0).toLowerCase() + name.slice(1);
					
				if (args.length > 0)
				{
					trace(_gameObject._name + "." + name + ": " + args.join(", "));
				}
				else
				{
					trace(_gameObject._name + "." + name + ": ");
					var info : XMLList = describeType(this).children();
					for each(var member : XML in info)
					{
						if ((member.name() == "variable" || member.name() == "accessor"))
						{
							trace("\t" + member.@name + ": " + this[member.@name]);
						}
					}
				}
			}
		}
	}

}