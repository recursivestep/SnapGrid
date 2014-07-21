 Extended flow layout class that allows user to drag cells around.
	Uses UIKit dynamics for snap effects.

 Notes:
	- Currently only supports a single section
	- If the content is larger than the view then cells can't be dragged outside
		the current scroll window. I think the way to implement this is detect
		proximity to edge of view and then start a timer to control scroll speed.
	- The constant used to detect if a cell is sufficiently over another slot to trigger
		a swap needs to be dynamic. Currently small values don't work well with large cells
		and large values are poor for small cells
	- Would be nice to allow users of this class to pass in UIDynamicItemBehavior objects
		to customise the animation effects.
