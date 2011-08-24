package com.jxl.planeshooter.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class LevelVO
	{
		
		public var events:ArrayCollection;
			
		public function LevelVO()
		{
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