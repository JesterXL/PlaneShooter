package com.jxl.planeshooter.events
{
	import flash.events.Event;
	
	public class OpenLevelServiceEvent extends Event
	{
		public static const OPEN_SUCCESS:String 	= "openSuccess";
		public static const OPEN_ERROR:String 		= "openError";
		
		public function OpenLevelServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}