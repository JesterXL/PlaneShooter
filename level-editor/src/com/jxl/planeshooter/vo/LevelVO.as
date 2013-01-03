package com.jxl.planeshooter.vo
{
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;

	public class LevelVO
	{
		private var _events:ArrayCollection;
		
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
		
		private var _totalTime:Number = 0;
		
		[Bindable]
		public function get totalTime():Number
		{
			return _totalTime;
		}
		public function set totalTime(value:Number):void
		{
			_totalTime = value;
			if(isNaN(_totalTime) == true)
			{
				_totalTime = 10;
			}
			
			if(_totalTime < 10)
			{
				_totalTime = 10;
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
				time += event.when;
			}
			totalTime = time;
		}
		
		public function toObject():Object
		{
			var obj:Object 					= {};
			obj.events 						= [];
			obj.totalTime					= 0;
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
		}
	}
}