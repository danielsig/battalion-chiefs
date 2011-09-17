package com.battalion.flashpoint.core 
{
	import flash.utils.getQualifiedClassName;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Extend this class in order to make new components.
	 * Do not instantate components yourself. Instead pass the type of a component as a parameter to certain methods within the GameObject class.
	 * <strong>Good Design Princibles</strong><p>
	 * Strive to make only exclusive Components. Always have a good reason for creating non-exclusive components.
	 * Make all your stateless components exclusive. A stateless Component is basicly a Component with no properties.
	 * The only exception to make a non-exclusive Component is if it fulfills any of the folowing requirements:
	 * </p>
	 * <ul>
	 * <li>The only public methods are awake, start, update, fixedUpdate and/or onDestroy.</li>
	 * <li>It's a concise component.</li>
	 * <li>It has exactly one public method.</li>
	 * </ul>
	 * @see IExclusiveComponent
	 * @see IConciseComponent
	 * @see GameObject
	 * @author Battalion Chiefs
	 */
	public class Component 
	{
		/** @private **/
		internal var _gameObject : GameObject;
		
		CONFIG::debug
		{
			/** @private **/
			internal var _requiredBy : Vector.<Component> = new Vector.<Component>();
			/** @private **/
			internal var _require : Vector.<Component> = new Vector.<Component>();
			public static function get world() : GameObject
			{
				return GameObject.WORLD;
			}
		}
		CONFIG::release
		public static var world : GameObject;
		
		/**
		 * This GameObject.
		 */
		public final function get gameObject() : GameObject
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
			}
			return _gameObject;
		}
		/**
		 * Destroys this Component.
		 */
		public final function destroy() : void
		{
			CONFIG::debug
			{
				if (this is IConciseComponent) throw new Error(this + " implements the IConciseComponent interface. Do not delete concise components manually, they do that automatically.");
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
			}
			removeComponent(this);
		}
		/** @private **/
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
		/**
		 * Use this to communicate with other Components in this GameObject.
		 * Calls every function named message on every Component in this GameObject.
		 * An exception to this is when you want to send a message only to a component of a specific type.
		 * 
		 * 
		 * @example Here's an example of how sendMessage works:<listing version="3.0">
		 * sendMessage("applyDamage", 10);
		 * //	myComponent: Ouch! -10Hp.
		 * //	myOtherComponent: Ouch! -10Hp.
		 * ...
		 * public class MyComponent extends component implements IExclusiveComponent
		 * {
		 * 	public function applyDamage(amount : int) : void
		 * 	{
		 * 		log("Ouch! -" + amount + "Hp.");
		 * 	}
		 * }
		 * ...
		 * public class MyOtherComponent extends component implements IExclusiveComponent
		 * {
		 * 	public function applyDamage(amount : int) : void
		 * 	{
		 * 		log("Ouch! -" + amount + "Hp.");
		 * 	}
		 * }</listing>
		 * @example Here's an example of how to send a message only to a component of a specific type:<listing version="3.0">
		 * sendMessage("MyComponent_applyDamage", 10);
		 * //	myComponent: Ouch! -10Hp.
		 * ...
		 * public class MyComponent extends component implements IExclusiveComponent
		 * {
		 * 	public function applyDamage(amount : int) : void
		 * 	{
		 * 		log("Ouch! -" + amount + "Hp.");
		 * 	}
		 * }
		 * ...
		 * public class MyOtherComponent extends component implements IExclusiveComponent
		 * {
		 * 	public function applyDamage(amount : int) : void
		 * 	{
		 * 		log("Ouch! -" + amount + "Hp.");
		 * 	}
		 * }</listing>
		 * @see #sendBefore()
		 * @see #sendAfter()
		 * @see #chain()
		 * @see #sequence()
		 * @param	message, the name of the message to send.
		 * @param	...args, the parameters to pass along with the function call.
		 */
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
				
				var indexOfUnderScore : int = message.indexOf("_");
				if (indexOfUnderScore > 0)
				{
					var functionName : String = message.slice(indexOfUnderScore + 1);
					var className : String = message.slice(0, indexOfUnderScore);
					className = className.charAt(0).toLowerCase() + className.slice(1);
					if (_gameObject.hasOwnProperty(className))
					{
						var targetClass : Class = getDefinitionByName(getQualifiedClassName(_gameObject[className])) as Class;
					}
					else
					{
						targetClass = null;
					}
				}
				else
				{
					functionName = message;
					targetClass = Component;
				}
				
				receivers = new Vector.<Function>();
				for each(var component : Component in _gameObject._components)
				{
					if (component is targetClass && component.hasOwnProperty(functionName))
					{
						receivers.push(component[functionName]);
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
		/**
		 * Use this to communicate with other Components in this GameObject.
		 * Like <a href="../core/Component.html#sendMessage()"><code>sendMessage()</code></a> except it differs the call until the target message has been sent.
		 * 
		 * @param	message, the function name to call on every Component in this GameObject.
		 * @param	target, the message that triggers this message, evidently preceding this message.
		 * @param	...args, the parameters to pass along with the function call.
		 */
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
		/**
		 * Use this to communicate with other Components in this GameObject.
		 * Like <a href="../core/Component.html#sendMessage()"><code>sendMessage()</code></a> except it differs the call until right before the target message will been sent.
		 * 
		 * @param	message, the function name to call on every Component in this GameObject.
		 * @param	target, the message that should succeed this message.
		 * @param	...args, the parameters to pass along with the function call.
		 */
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
		/**
		 * Use this to communicate with other Components in this GameObject.
		 * Chains together messages to be sent after the invoker message is sent.
		 * 
		 * @see #sendMessage()
		 * @param	invoker, the meessage name that triggers this chain of messages.
		 * @param	...messages, the messages to be chained.
		 */
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
		/**
		 * Use this to communicate with other Components in this GameObject.
		 * Like <a href="#chain()"><code>chain()</code></a> except that the first parameter is the invoker, and it is called right after the chain has been made.
		 * 
		 * @see #sendMessage()
		 * @param	...messages, the messages to be chained and called.
		 */
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
		/**
		 * Use this instead of trace when possible.
		 * @param	...args, if no arguments, the Component will list all it's properties and variables.
		 */
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