package com.battalion.flashpoint.core 
{
	
	/**
	 * Let your components implement this interface in order to make them
	 * inaccessable in any way except with the returned value of the
	 * function that added it to it's GameObject. Concise components (components that implements
	 * the IConciseComponent interface) are allways hidden. To make DynamicComponents hidden,
	 * simply set the <code>hidden</code> parameter of the <code>addDynamic()</code>
	 * method call to true.
	 * @author Battalion Chiefs
	 */
	public interface IHiddenComponent 
	{
		
	}
	
}