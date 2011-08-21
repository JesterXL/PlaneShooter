package com.jxl.planeshooter.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class LevelVO
	{
		/*
		- level
			[
				- when
				- type: enemy
				- enemy type
				- x, y
				- configuration(s) for enemy
				,
				- type: movie
				- events
				[
					- character name
					- character image
					- message
				]
			]
		*/
		
		public var events:ArrayCollection;

			
		public function LevelVO()
		{
		}
		
		public function toObject():Object
		{
			var obj:Object 					= {};
			obj.events 						= [];
			if(events && events.length > 0)
			{
				var len:int = events.length;
				while(len--)
				{
					obj.events[len] = events[len].toObject();
				}
			}
			
			return obj;
		}
	}
}