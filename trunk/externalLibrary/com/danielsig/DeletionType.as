package com.danielsig 
{
	/**
	 * A DeletionType enum.
	 * Here's a table that shows the value for each deletion type.
	 * In the illustrations:<ul>
		 * <li>$ = the $ sign in the string.</li>
		 * <li>| = the beginning and the end of the string.</li>
		 * <li>1 = the first side to delete from.</li>
		 * <li>2 = the second side to delete from.</li>
		 * <li>-&gt; = delete only one character from left to right, then switch to the other side of the $ sign.</li>
		 * <li>&lt;- = delete only one character from right to left, then switch to the other side of the $ sign.</li>
		 * <li>----&gt; = delete all the characters from left to right until enough has been deleted, or if the end has been reached, then it must switch to the other side of the $ sign.</li>
		 * <li>&lt;---- = delete all the characters from right to left until enough has been deleted, or if the end has been reached, then it must switch to the other side of the $ sign.</li>
		 * </ul>
<style type="text/css">
table
{
	background-color:#ffffff;
	border:1px solid #c3c3c3;
	border-collapse:collapse;
	width:100%;
	padding:0;
	margin:0;
	text-align:center;
}
td 
{
	border:1px solid #c3c3c3;
	padding:3px;
	vertical-align:top;
}
</style>
<table class="reference" style="width:30%">
	<tr>
		<td><pre>|   &lt;-1$   &lt;-2|</pre></td>
		<td>0</td>
	</tr>
	<tr>
		<td><pre>|   &lt;-2$   &lt;-1|</pre></td>
		<td>2</td>
	</tr>
	<tr>
		<td><pre>|1-&gt;   $   &lt;-2|</pre></td>
		<td>4</td>
	</tr>
	<tr>
		<td><pre>|2-&gt;   $   &lt;-1|</pre></td>
		<td>10</td>
	</tr>
	<tr>
		<td><pre>|   &lt;-2$1-&gt;   |</pre></td>
		<td>6</td>
	</tr>
	<tr>
		<td><pre>|   &lt;-1$2-&gt;   |</pre></td>
		<td>8</td>
	</tr>
	<tr>
		<td><pre>|1-&gt;   $2-&gt;   |</pre></td>
		<td>12</td>
	</tr>
	<tr>
		<td><pre>|2-&gt;   $1-&gt;   |</pre></td>
		<td>14</td>
	</tr>
	
	<tr>
		<td><pre>|------------&gt;|</pre></td>
		<td>13</td>
	</tr>
	<tr>
		<td><pre>|&lt;------------|</pre></td>
		<td>3</td>
	</tr>
	<tr>
		<td><pre>|&lt;----1$&lt;----2|</pre></td>
		<td>1</td>
	</tr>
	<tr>
		<td><pre>|2----&gt;$1----&gt;|</pre></td>
		<td>15</td>
	</tr>
	<tr>
		<td><pre>|1----&gt;$&lt;----2|</pre></td>
		<td>5</td>
	</tr>
	<tr>
		<td><pre>|2----&gt;$&lt;----1|</pre></td>
		<td>11</td>
	</tr>
	<tr>
		<td><pre>|&lt;----2$1----&gt;|</pre></td>
		<td>7</td>
	</tr>
	<tr>
		<td><pre>|&lt;----1$2----&gt;|</pre></td>
		<td>9</td>
	</tr>
</table>
	 */
	public final class DeletionType
	{
		public static const DELETE_EVENLY: uint = 0;
		public static const DELETE_UNEVENLY : uint = 1;
		
		public static const LEFT_SIDE_FIRST : uint = 0;
		public static const RIGHT_SIDE_FIRST : uint = 2;
		
		public static const FIRST_TOWARDS_LEFT : uint = 0;
		public static const FIRST_TOWARDS_RIGHT : uint = 4;
		public static const THEN_TOWARDS_LEFT : uint = 0;
		public static const THEN_TOWARDS_RIGHT : uint = 8;
		
		
		/**
		 * Create a deletion type setting.
		 * In a String that is about totif it should take turns deleting from either side.
		 * The second parameter defines if it should start deleting from the left side first(true) or the right side first(false).</pre>
		 * The third parameter defines where in the first side it should delete; from right to left(true) or left to right(false).
		 * The last parameter defines where in the later side it should delete; from left to right(true) or right to left(false).
		 * 
		 * @param	deleteEvenlyFromBothSides, determines if it should take turns delete from either side.
		 * @param	firstFromLeftSide, determines if it should start deleteing from the left side.
		 * @param	firstDeleteTowardsLeft, determines if it should start deleting from right to left on the first side.
		 * @param	thenDeleteTowardsRight, determines if it should start deleting from left to right on the later side.
		 * @return
		 */
		public static function create(deleteEvenlyFromBothSides : Boolean, firstFromLeftSide : Boolean, firstDeleteTowardsLeft : Boolean, thenDeleteTowardsRight : Boolean) : uint
		{
			if (deleteEvenlyFromBothSides) var deleteDir : uint = 0;
			else deleteDir = 1;
			if (!firstFromLeftSide) deleteDir |= 2;
			if (!firstDeleteTowardsLeft) deleteDir |= 4;
			if (thenDeleteTowardsRight) deleteDir |= 8;
			return deleteDir;
		}
		
		public function DeletionType()
		{
			throw new Error("DeletionType is an enum. Do not instantiate it!");
		}
	}

}