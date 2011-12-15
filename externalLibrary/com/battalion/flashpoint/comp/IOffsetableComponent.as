package com.battalion.flashpoint.comp 
{
	
	/**
	 * An interface for components that have an offset matrix, mainly for displayable components
	 * @author Battalion Chiefs
	 */
	public interface IOffsetableComponent 
	{
		function setOffset(x : Number, y : Number, scale : Number = 1) : void
		function translate(x : Number, y : Number) : void
		function scale(amount : Number) : void
	}
	
}