package com.jxl.planeshooter.events
{
	import com.jxl.planeshooter.vo.MovieVO;
	
	import flash.events.Event;
	
	public class EventItemRendererEvent extends Event
	{
		public static const EDIT_MOVIE:String = "editMovie";
		
		public var movie:MovieVO;
		
		public function EventItemRendererEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}