package com.jxl.planeshooter.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class MovieVO
	{
		public var when:int								= 0;
		public var pause:Boolean						= true;
		public var name:String							= "Default Movie";
		public var dialogues:ArrayCollection			= new ArrayCollection();
		
		public function MovieVO()
		{
		}
		
		public function toObject():Object
		{
			var obj:Object 		= {};
			obj.classType 		= "movie";
			obj.when			= when;
			obj.pause			= pause;
			obj.name 			= name;
			obj.dialogues		= [];
			if(dialogues && dialogues.length > 0)
			{
				var len:int = dialogues.length;
				while(len--)
				{
					obj.dialogues[len] = dialogues[len].toObject();
				}
			}
			return obj;	
		}
	}
}