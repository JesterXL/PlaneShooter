package com.jxl.planeshooter.events
{
	import flash.events.Event;
	
	public class SaveLevelServiceEvent extends Event
	{
		public static const SAVE_SUCCESS:String = "saveSuccess";
		public static const SAVE_ERROR:String = "saveError";
		
		public function SaveLevelServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}