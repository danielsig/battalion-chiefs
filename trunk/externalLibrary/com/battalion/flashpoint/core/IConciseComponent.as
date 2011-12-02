package com.battalion.flashpoint.core 
{
	
	/**
	 * An Interface for Concise Components.
	 * Concise Components must have a concise method, a method with the same name as the Component, except it begins with a lower case letter.
	 * Here's a list of differences between a Concise Component and a normal one:
	 * <ul>
	 * <li>
	 * <b>Speed: </b>Concise components are faster to add and faster to remove than normal Components, about twice as fast on average.
	 * </li>
	 * <li>
	 * <b>Acessability: </b>Concise Components are not accessable through the dot operator like normal components.
	 * </li>
	 * <li>
	 * <b>Messaging: </b>Concise Components do not receive any messages except it's concise method.
	 * </li>
	 * </ul>
	 * @author Battalion Chiefs
	 */
	public interface IConciseComponent extends IHiddenComponent
	{
		
	}
	
}