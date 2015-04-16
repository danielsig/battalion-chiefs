<h1>FlashPoint</h1>

FlashPoint is a component based game engine written in Actionscript 3 designed with the Unity3D API in mind.
It uses the PowerGrid physics engine and an Audio framework, both of which can be found inside this repo.

In order to download FlashPoint, you must download the entire externalLibrary directory.

In order to download the Audio framework, you simply have to download the Audio directory.

<h1>PowerGrid</h1>

PowerGrid is a physics engine used by FlashPoint. It's grid based and therefor it has a growth rate complexity of n, not n^2 like most physics engines. This means that it's basically the fastest AS3 physics engine available.

<h2>Details</h2>
In our tests on a HP ProBook 4520s with 6 GB ram and 2.53Ghz dual core i3 intel CPU, Powergrid can simulate up to 1000 rigidbodies at 30fps with every single rigidbody touching at least one other rigidbody. With no rigidbodies colliding it can simulate at least a few thousands more.

It can simulate as many sleeping rigidbodies as the computer can store in memory, not a single operation is made for sleeping rigidbodies, they're simply not processed. Still, they wake up if something collides with them (Yes, you guessed it right, it's sorcery).

Having most moving objects similar in size boosts performance. This fortunately happens to be the case with most games.

When initializing the engine, you must specify a BitmapData? object as the grid. Every pixel in the BitmapData? object is a tile. The value of the pixel is the collision layer that it collides with.

<h5>PROS</h5>
<ul>
<li>Decent API and documentation</li>
<li>Supports tile-maps with tile collisions</li>
<li>Supports collision layers (collision filters)</li>
<li>Has 2 primitive rigidbodies: Triangle and Circle</li>
<li>Supports groups (compound rigidbodies)</li>
<li>INSANELY FAST!!!</li>
</ul>
<h5>CONS</h5>
<ul>
<li>All rigidbodies are stuck inside the grid you specify</li>
<li>Huge moving objects can slow things down</li>
<li>The source is barely readable</li>
</ul>

In order to download PowerGrid, you simply have to download the PowerGrid directory.
