package com.battalion.flashpoint.core 
{
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.*;
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public final dynamic class GameObject 
	{
		
		internal static var WORLD : GameObject;
		
		CONFIG::debug
		public static function get world() : GameObject
		{
			return WORLD;
		}
		CONFIG::debug
		public function get transform() : Transform
		{
			return _transform;
		}
		CONFIG::debug
		internal var _transform : Transform;
		
		CONFIG::release
		public static var world : GameObject;
		CONFIG::release
		public var transform : Transform;
		
		internal var _name : String;
		internal var _parent : GameObject = WORLD;
		internal var _children : Vector.<GameObject> = new Vector.<GameObject>();
		internal var _components : Vector.<Component>;
		internal var _messages : Object = { };
		internal var _after : Object = { };
		internal var _before : Object = { };
		internal var _update : Vector.<Function> = new Vector.<Function>();
		internal var _fixedUpdate : Vector.<Function> = new Vector.<Function>();
		
		
		public function get parent() : GameObject
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			return _parent == WORLD ? null : _parent;
		}
		public function set parent(value : GameObject) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			(value || WORLD).addChild(this);
		}
		
		public function get name() : String
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			return _name;
		}
		public function set name(value : String) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (value == null) throw new Error("Name must be non null.");
			}
			_parent.updateNameOf(this, value);
			_name = value;
		}
		
		public function GameObject(...args)
		{
			if (args.length && args[0] is String)
			{
				_name = args.shift();
			}
			else
			{
				_name = "Untitled";
			}
			if (WORLD)
			{
				parent = WORLD;
			}
			
			_components = new Vector.<Component>(args.length + 1);
			var index : int = 0;
			
			CONFIG::debug
			{
				_transform = (_components[index++] = new Transform()) as Transform;
				_transform._gameObject = this;
			}
			CONFIG::release
			{
				transform = (_components[index++] = new Transform()) as Transform;
				transform._gameObject = this;
			}
			
			for each(var comp : Class in args)
			{
				CONFIG::debug
				{
					if (!Util.isComponent(comp)) throw new Error(comp + " does not extend " + Component + ".");
				}
				
				var component : Component = _components[index++] = new comp();//faster than push()
				component._gameObject = this;
				
				var name : String = getQualifiedClassName(component);
				name = name.slice(name.lastIndexOf("::") + 2);
				name = name.charAt(0).toLowerCase() + name.slice(1);
				this[name] = component;
				
				var compObj : Object = component;
				if (compObj.hasOwnProperty("update"))
				{
					_update.push(compObj.update);
				}
				if (compObj.hasOwnProperty("fixedUpdate"))
				{
					_fixedUpdate.push(compObj.fixedUpdate);
				}
				if (compObj.hasOwnProperty("awake"))
				{
					compObj.awake();
				}
			}
			_components.length = index;
		}
		
		private function updateNameOf(child : GameObject, newName : String) : void
		{
			var oldName : String = child._name;
			delete this[oldName];
			for each(var otherChild : GameObject in _children)
			{
				if (otherChild._name == oldName)
				{
					this[oldName] = otherChild;
					break;
				}
			}
		}
		
		public function addChildren(...children) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (!children.length) throw new Error("Expecting at least one child as parameter.");
				for each(var obj : * in children)
				{
					if (!obj || !(obj is GameObject))
					{
						throw new Error(obj + " is not a GameObject.");
					}
				}
			}
			for each(var child : GameObject in children)
			{
				_children.push(child);
				child._parent.unparentChild(child);
				child._parent = this;
				this[child._name] = child;
			}
		}
		public function removeChildren(...children) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (!children.length) throw new Error("Expecting at least one child as parameter.");
				for each(var obj : * in children)
				{
					if (!obj || !(obj is GameObject))
					{
						throw new Error(obj + " is not a GameObject.");
					}
					else
					{
						if (obj._parent != this)
						{
							throw new Error("GameObject does not contain the specified child.");
						}
					}
				}
			}
			for each(var child : GameObject in children)
			{
				WORLD.addChild(child);
			}
		}
		
		public function addChild(child : GameObject) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (child == null) throw new Error("Child must be non null.");
			}
			child._parent.unparentChild(child);
			_children.push(child);
			child._parent = this;
			this[child._name] = child;
		}
		public function removeChild(child : GameObject) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (child == null) throw new Error("Child must be non null.");
				if (child._parent != this) throw new Error("GameObject does not contain the specified child.");
			}
			WORLD.addChild(child);
		}
		private function unparentChild(child : GameObject) : void
		{
			var index : int = _children.indexOf(child);
			if (index > -1)
			{
				if (index < _children.length - 1)
				{
					_children[index] = _children.pop();
				}
				else
				{
					_children.length--;
				}
				delete this[child._name];
			}
		}
		
		public function getChildrenNames() : Vector.<String>
		{
			var names : Vector.<String> = new Vector.<String>(_children.length);
			var c : int = _children.length;
			while (c--)
			{
				names[c] = _children[c].name;
			}
			return names;
		}
		public function getComponents(type : Class) : Vector.<Component>
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non null.");
			}
			var results : Vector.<Component> = new Vector.<Component>();
			for each(var component : Component in _components)
			{
				if (component is type)
				{
					results.push(component);
				}
			}
			return results;
		}
		public function haveComponent(type : Class) : Boolean
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non null.");
			}
			for each(var component : Component in _components)
			{
				if (component is type)
				{
					return true;
				}
			}
			return false;
		}
		public function getComponent(type : Class) : Component
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (type == null) throw new Error("Type must be non null.");
			}
			for each(var component : Component in _components)
			{
				if (component is type)
				{
					return component;
				}
			}
			return null;
		}
		
		public function destroy() : void
		{
			CONFIG::debug
			{
				if (this == WORLD) throw new Error("\r\tI was just chilling, minding my own business when suddenly you call this method:\r\t\t\"GameObject.world.destroy();\"\r\tOMG you're such a NOOB!");
			}
			_parent.unparentChild(this);
			_parent = null;
		}
		
		
		public function addConcise(comp : Class, message : String) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null."); 
				if (!Util.isComponent(comp)) throw new Error(comp + " does not extend " + Component + ".");
				if (!Util.isConcise(comp)) throw new Error(comp + " does not implement the IConciseComponent interface.");
			}
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			//TODO: optimize, remove function call
			var precursor : Component = getComponent(comp);
			if (precursor && precursor is IExclusiveComponent)
			{
				return;
			}
			
			var instance : Component = new comp();
			instance._gameObject = this;
			_components.push(instance);
			
			CONFIG::debug
			{
				if (!instance.hasOwnProperty(message) || !(instance[message] is Function))
				{
					throw new Error(instance + " does not contain a function named " + message + "."); 
				}
			}
			
			if (!_after.hasOwnProperty(message))
			{
				_after[message] = { };
			}
			if (!_after[message].destroyConcise)
			{
				_after[message].destroyConcise = [instance.destroyConcise];
			}
			else
			{
				_after[message].destroyConcise.push(instance.destroyConcise);
			}
			
			if (!_messages.hasOwnProperty(message))
			{
				_messages[message] = new <Function>[instance[message]];
			}
			else
			{
				_messages[message].push(instance[message]);
			}
		}
		public function addComponent(comp : Class) : Component
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (comp == null) throw new Error("Comp must be non null."); 
				if (!Util.isComponent(comp)) throw new Error(comp + " does not extend " + Component + ".");
				if (Util.isConcise(comp)) throw new Error(comp + " implements the IConciseComponent interface. Please use the addConcise() method instead.");
			}
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			//TODO: optimize, remove function call
			var precursor : Component = getComponent(comp);
			if (precursor && precursor is IExclusiveComponent)
			{
				return precursor;
			}
			var instance : Component = new comp();
			instance._gameObject = this;
			_components.push(instance);
			
			var name : String = getQualifiedClassName(instance);
			name = name.slice(name.lastIndexOf("::") + 2);
			name = name.charAt(0).toLowerCase() + name.slice(1);
			this[name] = instance;

			for (var message : String in _messages)
			{
				if (instance.hasOwnProperty(message))
				{
					CONFIG::debug
					{
						if (!(instance[message] is Function)) throw new Error("the property " + message + " of " + instance + " conflicts with a message with the same name."); 
					}
					_messages[message].push(instance[message]);
				}
			}
			
			var compObj : Object = instance;
			if (compObj.hasOwnProperty("update"))
			{
				_update.push(compObj.update);
			}
			if (compObj.hasOwnProperty("fixedUpdate"))
			{
				_fixedUpdate.push(compObj.fixedUpdate);
			}
			if (compObj.hasOwnProperty("awake"))
			{
				compObj.awake();
			}
			
			return instance;
		}
		
		public function removeComponent(instance : Component) : void
		{
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (instance == null) throw new Error("Instance must be non null."); 
				if (_components.indexOf(instance) < 0) throw new Error("GameObject does not contain " + instance + "." );
				if (instance._requiredBy.length > 0)
				{
					throw new Error("Component " + instance + " can not be removed. It is required by "
					+ (instance._requiredBy.length > 1 ? "the following: [" + instance._requiredBy.join(", ") + "]." : instance._requiredBy[0]));
				}
				if (instance._require.length > 0)
				{
					for each(var requiredComponent : Component in instance._require)
					{
						requiredComponent._requiredBy = requiredComponent._requiredBy.filter(
							function(c : Component, i : int, v : Vector.<Component>) : Boolean
							{
								return c != instance;
							}
						);
					}
				}
			}
			
			var compObj : Object = instance;
			if (compObj.hasOwnProperty("update"))
			{
				var index : int = _update.lastIndexOf(compObj.update);
				if (index < _update.length - 1)
				{
					_update[index] = _update.pop();
				}
				else
				{
					_update.length--;
				}
			}
			if (compObj.hasOwnProperty("fixedUpdate"))
			{
				index  = _fixedUpdate.lastIndexOf(compObj.fixedUpdate);
				if (index < _fixedUpdate.length - 1)
				{
					_fixedUpdate[index] = _fixedUpdate.pop();
				}
				else
				{
					_fixedUpdate.length--;
				}
			}
			
			for (var message : String in _messages)
			{
				if (instance.hasOwnProperty(message))
				{
					var rcv : Vector.<Function> = _messages[message];
					index = rcv.indexOf(instance[message]);
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
			}
			var instanceIndex : int = _components.indexOf(instance);
			if (instanceIndex < _components.length - 1)
			{
				_components[instanceIndex] = _components.pop();
			}
			else
			{
				_components.length--;
			}
			instance._gameObject = null;
			
			var deleteComponent : Boolean = true;
			var type : Class = Class(getDefinitionByName(getQualifiedClassName(instance)))
			for each(var component : Component in _components)
			{
				if (component is type)
				{
					var name : String = getQualifiedClassName(component);
					name = name.slice(name.lastIndexOf("::") + 2);
					name = name.charAt(0).toLowerCase() + name.slice(1);
					this[name] = component;
					deleteComponent = false;
					break;
				}
			}
			if(deleteComponent)
			{
				delete this[name];
			}
		}
		public function sendMessage(message : String, ...args) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
			}
			if (_components.length)
			{
				_components[0].sendMessage.apply(_components[0], [message].concat(args));
			}
		}
		public function sendAfter(message : String, target : String, ...args) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
				if (target == null) throw new Error("Target must be non null.");
			}
			if (_components.length)
			{
				_components[0].sendAfter.apply(_components[0], [message, target].concat(args));
			}
		}
		public function sendBefore(message : String, target : String, ...args) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
				if (message == null) throw new Error("Message must be non null.");
				if (target == null) throw new Error("Target must be non null.");
			}
			if (_components.length)
			{
				_components[0].sendBefore.apply(_components[0], [message, target].concat(args));
			}
		}
		public function chain(invoker : String, ...messages) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			if (_components.length)
			{
				_components[0].chain.apply(_components[0], [invoker].concat(messages));
			}
		}
		public function sequence(...messages) : void
		{
			//TODO: Optimize
			CONFIG::unoptimized{ throw new Error("This function can be optimized further by copy pasting code hence avoiding function calls"); }
			CONFIG::debug
			{
				if (!_parent) throw new Error("GameObject has been destroyed, but you're trying to access it");
			}
			if (_components.length)
			{
				_components[0].sequence.apply(_components[0], messages);
			}
		}
		internal function update() : void
		{
			for each(var f : Function in _update)
			{
				f();
			}
			for each(var child : GameObject in _children)
			{
				child.update();
			}
			CONFIG::debug
			{
				_transform.flush();
			}
			CONFIG::release
			{
				transform.flush();
			}
		}
		internal function fixedUpdate() : void
		{
			for each(var f : Function in _fixedUpdate)
			{
				f();
			}
			for each(var child : GameObject in _children)
			{
				child.fixedUpdate();
			}
		}
	}
}