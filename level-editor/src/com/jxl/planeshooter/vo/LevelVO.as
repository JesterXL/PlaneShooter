package com.jxl.planeshooter.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;

	public class LevelVO extends EventDispatcher
	{
		private var _events:ArrayCollection = new ArrayCollection();
		private var _totalTime:Number = 0;
		
		[Bindable] public var name:String;
		[Bindable] public var description:String;
		[Bindable] public var musicFile:String;
		
		[Bindable]
		public function get events():ArrayCollection { return _events; }
		public function set events(value:ArrayCollection):void
		{
			if(_events)
			{
				_events.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onChanged);
			}
			_events = value;
			if(_events)
			{
				_events.addEventListener(CollectionEvent.COLLECTION_CHANGE, onChanged);
			}
		}
		
		
		
		[Bindable(event="totalTimeChanged")]
		public function get totalTime():Number
		{
			return _totalTime;
		}
		public function set totalTime(value:Number):void
		{
			var old:Number = _totalTime;
			_totalTime = value;
			if(isNaN(_totalTime) == true)
			{
				_totalTime = 10;
			}
			
			if(_totalTime < 10)
			{
				_totalTime = 10;
			}
			
			if(old != _totalTime)
			{
				dispatchEvent(new Event("totalTimeChanged"));
			}
		}
			
		public function LevelVO()
		{
		}
		
		private function onChanged(event:CollectionEvent):void
		{
			recalculateTotalTime();
		}
		
		private function recalculateTotalTime():void
		{
			var len:int = events.length;
			var time:Number = 0;
			while(len--)
			{
				var event:EventVO = events[len];
				// TODO: beware, if someone removes the event, this event listener isn't necessarely removed, ack.
				event.removeEventListener("whenChanged", onWhenChanged);
				event.addEventListener("whenChanged", onWhenChanged, false, 0, true);
				time = Math.max(time, event.when);
			}
			totalTime = time;
		}
		
		private function onWhenChanged(event:Event):void
		{
			recalculateTotalTime();
		}
		
		public function toObject():Object
		{
			var obj:Object 					= {};
			obj.events 						= [];
			obj.totalTime					= 0;
			obj.name 				= name;
			obj.description 				= description;
			obj.musicFile 					= musicFile;
			if(events && events.length > 0)
			{
				var len:int = events.length;
				while(len--)
				{
					obj.events[len] = events[len].toObject();
				}
				obj.events.sortOn("when", Array.NUMERIC);
				var lastObj:* = obj.events[obj.events.length - 1];
				if(lastObj)
					obj.totalTime = lastObj.when;
			}
			
			return obj;
		}
		
		public function buildFromObject(obj:Object):void
		{
			events					= new ArrayCollection();
			if(obj.events && obj.events.length > 0)
			{
				var len:int				= obj.events.length;
				for(var index:int = 0; index < len; index++)
				{
					var enemy:EnemyVO;
					var movie:MovieVO;
					var eventObj:Object = obj.events[index];
					if(eventObj.classType == "enemy")
					{
						enemy = new EnemyVO();
						enemy.buildFromObject(eventObj);
						events.addItem(enemy);
					}
					else if(eventObj.classType == "movie")
					{
						movie = new MovieVO();
						movie.buildFromObject(eventObj);
						events.addItem(movie);
					}
					else
					{
						throw new Error("Unknown event type!");
					}
				}
			}
			
			name 					= obj.name;
			description 			= obj.description;
			musicFile 				= obj.musicFile;
		}
	}
}