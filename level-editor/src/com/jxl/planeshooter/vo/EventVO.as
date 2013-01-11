package com.jxl.planeshooter.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class EventVO extends EventDispatcher
	{
		private var _when:Number = 0;
		
		public function get when():Number { return _when; }
		public function set when(value:Number):void
		{
			_when = value;
			dispatchEvent(new Event("whenChanged"));
		}
		
		public function EventVO()
		{
		}
	}
}