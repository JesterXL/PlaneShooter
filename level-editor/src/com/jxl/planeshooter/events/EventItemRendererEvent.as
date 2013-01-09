package com.jxl.planeshooter.events
{
	import com.jxl.planeshooter.vo.MovieVO;
	
	import flash.events.Event;
	
	public class EventItemRendererEvent extends Event
	{
		public static const EDIT_MOVIE:String = "editMovie";
		public static const DELETE_ITEM:String = "deleteItem";
		public static const TIME_CHANGED:String = "timeChanged";
		public static const EVENT_CLICKED:String = "eventClicked";
		
		public var movie:MovieVO;
		public var item:*;
		
		public function EventItemRendererEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}