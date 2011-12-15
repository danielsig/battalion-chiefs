package com.battalion.flashpoint.comp 
{
	
	/**
	 * ...
	 * @author Battalion Chiefs
	 */
	public interface IRotatableComponent extends IOffsetableComponent
	{
		function setOffsetRotation(x : Number, y : Number, scale : Number = 1, rotation : Number = 0) : void
		function rotate(amount : Number) : void
	}
	
}