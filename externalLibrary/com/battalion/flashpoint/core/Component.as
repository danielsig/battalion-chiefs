package com.battalion.flashpoint.core 
{
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import com.battalion.Input;
	import com.battalion.flashpoint.comp.tools.Console;
	
	/**
	 * Extend this class in order to make new components.
	 * Do not instantate components yourself. Instead pass the type of a component as a parameter to certain methods within the GameObject class.<pre>
</pre>	 * <strong>Good Design Princibles</strong><p>
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
			/**
			 * The world GameObject.
			 */
			public static function get world() : GameObject
			{
				return GameObject.WORLD;
			}
			protected var _privateMemberNames : Vector.<String> = new <String>["_gameObject"];
			protected function getPrivate(name : String) : * { return this[name]; }
		}
		/**
		 * The world GameObject.
		 */
		CONFIG::release
		public static var world : GameObject;
		
		/**
		 * This is clearly obvious.
		 */
		public final function get isDestroyed() : Boolean
		{
			return !_gameObject;
		}
		
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
		/**
		 * Copy properties from another component of the same type
		 * @param	original
		 */
		public function copyFrom(original : Component) : void
		{
			var info : XMLList = describeType(original).children();
			for each(var member : XML in info)
			{
				if ((member.name() == "variable" || member.name() == "accessor"))
				{
					this[member.@name] = original[member.@name];
				}
			}
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
		/**
		 * Add a listener to a specific message named <code>messageName</code> so that when
		 * that message is sent, the callbackFunction is called.
		 * @param	messageName, the name of the message to listen to
		 * @param	callbackFunction, the function to call when the message will be sent
		 */
		public function addListener(messageName : String, callbackFunction : Function, firstParamIsGameObject : Boolean = false) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (!messageName) throw new Error("MessageName must be non-null.");
				if (callbackFunction == null) throw new Error("CallbackFunction must be non-null.");
			}
			if (!_gameObject._listeners[messageName]) _gameObject._listeners[messageName] = new Dictionary();
			else if (_gameObject._listeners[messageName][callbackFunction]) return;
			var obj : Object = { };
			if (firstParamIsGameObject)
			{
				(_gameObject._listeners[messageName][callbackFunction] = _gameObject.addDynamic(messageName + "Listener", null, true)).addFunction(messageName, callbackFunction, true);
			}
			else
			{
				obj[messageName] = callbackFunction;
				_gameObject._listeners[messageName][callbackFunction] = _gameObject.addDynamic(messageName + "Listener", obj, true);
			}
			
		}
		/**
		 * remove a previously added listener
		 * @param	messageName, the name of the message that is being listened to and should be removed
		 * @param	callbackFunction, the function that should bre removed that is being called when message named <code>messageName</code> is sent
		 */
		public function removeListener(messageName : String, callbackFunction : Function) : void
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (!messageName) throw new Error("MessageName must be non-null.");
				if (callbackFunction == null) throw new Error("CallbackFunction must be non-null.");
			}
			if (_gameObject._listeners[messageName] && _gameObject._listeners[messageName][callbackFunction])
			{
				_gameObject.removeComponent(_gameObject._listeners[messageName][callbackFunction]);
				delete _gameObject._listeners[messageName][callbackFunction];
			}
		}
		/**
		 * Use this to add a DynamicComponent.
		 * @param	name, the name of the dynamic component
		 * @param	properties, an Object containing properties and methods that should be placed in the DynamicComponent instance.
		 * @param	hidden, Boolean indicating if this DynamicComponent should be hidden (see IHiddenComponent).
		 * @return	the DynamicComponent instance.
		 */
		public final function addDynamic(name : String, properties : Object = null, hidden : Boolean = false) : DynamicComponent
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (!name) throw new Error("Name must be non-null.");
			}
			return _gameObject.addDynamic(name, properties, hidden);
		}
		/**
		 * @see GameObject.addConcise()
		 * @param	comp
		 * @param	lowerCaseName
		 */
		public final function addConcise(comp : Class, lowerCaseName : String) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null.");
			}
			_gameObject.addConcise(comp, lowerCaseName);
		}
		/**
		 * @see GameObject.addComponent()
		 * @param	comp
		 * @return
		 */
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
		/**
		 * Makes this component dependant on another component class <code>comp</code>
		 * in a way that there must be at least one instance of that component on it's GameObject.
		 * @see #releaseComponent()
		 * @param	comp, the component to be dependant on.
		 * @return an instance of required component.
		 */
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
				if (_require.indexOf(instance) < 0)
				{
					instance._requiredBy.push(this);
					_require.push(instance);
				}
			}
			return instance;
		}
		/**
		 * Undo the requiring of a component, that is, after calling this
		 * the required component can be successfully destroyed.
		 * @see #requireComponent()
		 * @param	comp, the component that this component is dependant on.
		 * @return	the component instance that this component was previously dependant on.
		 */
		public final function releaseComponent(comp : Class) : Component
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null.");
				if (Util.isConcise(comp)) throw new Error(comp + " implements the IConciseComponent interface. A component may not require and therefor not release a concise component.");
			}
			var name : String = getQualifiedClassName(comp);
			name = name.slice(name.lastIndexOf("::") + 2);
			name = name.charAt(0).toLowerCase() + name.slice(1);
			if (_gameObject.hasOwnProperty(name))
			{
				var instance : Component = _gameObject[name];
			}
			CONFIG::debug
			{
				var index : uint = _require.indexOf(instance);
				if (index > -1)
				{
					instance._requiredBy.splice(instance._requiredBy.indexOf(this), 1);
					_require.splice(index, 1);
				}
			}
			return instance;
		}
		private function emptyFunction(...args) : void { }
		/**
		 * Call this method in order to alter your function pointers.
		 * The term function pointer in this context is a property of a component
		 * that is of type Function. In other words, it is a public variable
		 * that can reference an actual function.
		 * <p>
		 * If that function pointer is an update, fixedUpdate or a start function,
		 * or a message handler (function called using the sendMessage() method),
		 * and you change it with a simple assignment, then it's not likely you'll
		 * see any changes. Instead, use this method to change function pointers.
		 * </p>
		 * @param	pointerName
		 * @param	value
		 */
		public final function setFunctionPointer(pointerName : String, value : Function) : void
		{
			var thisComp : * = this;
			if (thisComp.hasOwnProperty(pointerName) && (thisComp[pointerName] is Function || thisComp[pointerName] == null))
			{
				var oldFunction : Function = thisComp[pointerName];
				value ||= emptyFunction;
				if (value == oldFunction) return;
				CONFIG::debug
				{
					try
					{
						thisComp[pointerName] = value;
					}
					catch (error : Error)
					{
						throw new Error(pointerName + " is not a function pointer, it's an actual function.\nPlease change it to a public variable that references a function before calling this method.");
					}
				}
				CONFIG::release
				{
					thisComp[pointerName] = value;
				}
				
				var functionArray : Vector.<Function> = null;
				switch(pointerName)
				{
					case "update" :
						functionArray = _gameObject._update;
						break;
					case "fixedUpdate" :
						functionArray = _gameObject._fixedUpdate;
						break;
					case "start" :
						functionArray = _gameObject._start;
						break;
				}
				var done : Boolean = false;
				do
				{
					if (functionArray)
					{
						var index : int = functionArray.lastIndexOf(oldFunction);
						if (index >= 0)
						{
							functionArray[index] = value;
						}
					}
					functionArray = _gameObject._messages[pointerName];
				}
				while (!(done = !done));
			}
			else
			{
				throw new Error("Function pointer " + pointerName + " was not found on " + this + ".");
			}
		}
		/**
		 * Use this to communicate with other Components in this GameObject.
		 * Calls every function named message on every Component in this GameObject.
		 * An exception to this is when you want to send a message only to a component of a specific type.
		 * The returned Boolean indicates if this component or it's GameObject has been destroyed.
		 * It is wise to put a sendMessage call inside an 'if' statement and terminate when it returns true
		 * since a destroyed component isn't supposed to have any effect any more.
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
		 *  @example Here's an example of how one could handle the return value of the sendMessage method:<listing version="3.0">
		 * if(sendMessage("applyDamage", 10)) return;
		 * </listing>
		 * @see #sendBefore()
		 * @see #sendAfter()
		 * @see #chain()
		 * @see #sequence()
		 * @param	message, the name of the message to send.
		 * @param	...args, the parameters to pass along with the function call.
		 * @return Boolean, true if sending the message has resulted in a self destruct, otherwise false.
		 */
		public final function sendMessage(message : String, ...args) : Boolean
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
						return false;
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
					if (component is targetClass && component.hasOwnProperty(functionName) && component[functionName] is Function)
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
					if (!_gameObject || !_gameObject._parent) return true;
				}
				delete _gameObject._before[message];
			}
			for each(var receiver : Function in receivers)
			{
				receiver.apply(this, args);
				if (!_gameObject || !_gameObject._parent) return true;
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
							if (!_gameObject || !_gameObject._parent) return true;
						}
					}
					else
					{
						sendMessage.apply(this, msg[after]);
						if (!_gameObject || !_gameObject._parent) return true;
					}
				}
				delete _gameObject._after[message];
			}
			return !_gameObject || !_gameObject._parent;
		}
		/**
		 * Use this method to determine if there's any component added to this
		 * GameObject that can receive a specific message. Useful for optimizations where the information sent with .
		 * @param	message, the message to check for in every component on this GameObject.
		 * @return true if there's a component that would listen to the specified message, otherwise false.
		 */
		public final function haveReceiver(message : String) : Boolean
		{
			CONFIG::debug
			{
				if (!_gameObject || _gameObject._components.indexOf(this) < 0) throw new Error("Component has been removed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
			}
			var msg : Object = _gameObject._messages;
			var receivers : Vector.<Function> = msg[message];
			if (receivers)
			{
				return receivers.length > 0;
			}
			else
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
					if (component is targetClass && component.hasOwnProperty(functionName) && component[functionName] is Function)
					{
						receivers.push(component[functionName]);
					}
				}
				msg[message] = receivers;
				return receivers.length > 0;
			}
			/*
			var underScore : int = message.indexOf("_");
			if (underScore >= 0)
			{
				var name : String = message.charAt(0).toLowerCase() + message.slice(1, underScore);
				if (_gameObject[name] && _gameObject[name].hasOwnProperty(message.slice(underScore + 1))) return true;
				return false;
			}
			for each(var comp : Object in _gameObject._components)
			{
				if (comp.hasOwnProperty(message))
				{
					return true;
				}
			}
			return false;
			*/
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
		 * Just like log, except that this will only log if the gameObject's name property matches the <code>gameObjectName</code> parameter.
		 * @param gameObjectName, the name of the GameObject to log on.
		 * @param	...args, if no arguments, the Component will list all it's properties and variables.
		 */
		public function logOn(gameObjectName : String, ...args) : Boolean
		{
			if (gameObject.name == gameObjectName)
			{
				log.apply(this, args);
				return true;
			}
			return false;
		}
		public function logPrivateMembers() : void
		{
			CONFIG::debug
			{
				var name : String = getQualifiedClassName(this);
				name = name.slice(name.lastIndexOf("::") + 2);
				name = name.charAt(0).toLowerCase() + name.slice(1);
				
				trace("2:" + _gameObject._name + "." + name + ": ");
				for each(var member : String in _privateMemberNames)
				{
					var value : * = getPrivate(member);
					if (getQualifiedClassName(value) == "Object")
					{
						var string : String = "{";
						for (var valueMember : String in value)
						{
							string += valueMember + ":" + value[valueMember] + ", ";
						}
						value = string.slice(0, -2) + "}";
					}
					trace("2:\t" + member + ": " + value);
				}
			}
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
					var string : String = _gameObject._name + "." + name + ": ";
					if (args[0] is Point)
					{
						string += "{ x:" + args[0].x.toFixed(2) + ", y:" + args[0].y.toFixed(2) + " }";
					}
					else
					{
						string += args[0];
					}
					for (var i : int = 1; i < args.length; i++ )
					{
						if (args[i] is Point)
						{
							string += ", { x:" + args[i].x.toFixed(2) + ", y:" + args[i].y.toFixed(2) + " }";
						}
						else
						{
							string += ", " + args[i];
						}
					}
					trace(string);
				}
				else
				{
					trace("3:" + _gameObject._name + "." + name + ": ");
					var info : XMLList = describeType(this).children();
					for each(var member : XML in info)
					{
						if ((member.name() == "variable" || member.name() == "accessor"))
						{
							trace("4:\t" + member.@name + ": " + this[member.@name]);
						}
					}
				}
			}
			CONFIG::release
			{
				var console : Console = Console.getConsole();
				if (!console) return;
				var name : String = getQualifiedClassName(this);
				name = name.slice(name.lastIndexOf("::") + 2);
				name = name.charAt(0).toLowerCase() + name.slice(1);
				
				if (args.length > 0)
				{
					var string : String = _gameObject._name + "." + name + ": ";
					if (args[0] is Point)
					{
						string += "{ x:" + args[0].x.toFixed(2) + ", y:" + args[0].y.toFixed(2) + " }";
					}
					else
					{
						string += args[0];
					}
					for (var i : int = 1; i < args.length; i++ )
					{
						if (args[i] is Point)
						{
							string += ", { x:" + args[i].x.toFixed(2) + ", y:" + args[i].y.toFixed(2) + " }";
						}
						else
						{
							string += ", " + args[i];
						}
					}
					console.writeLine(string);
				}
				else
				{
					console.writeLine(_gameObject._name + "." + name + ": ");
					var info : XMLList = describeType(this).children();
					for each(var member : XML in info)
					{
						if ((member.name() == "variable" || member.name() == "accessor"))
						{
							console.writeLine("\t" + member.@name + ": " + this[member.@name]);
						}
					}
				}
			}
		}	
	}

}