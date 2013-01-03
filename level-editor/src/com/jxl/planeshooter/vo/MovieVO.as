package com.jxl.planeshooter.vo
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class MovieVO extends EventVO
	{
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
		
		public function buildFromObject(obj:Object):void
		{
			when 				= obj.when;
			pause				= obj.pause;
			name				= obj.name;
			dialogues 			= new ArrayCollection();
			if(obj.dialogues && obj.dialogues.length > 0)
			{
				var len:int = obj.dialogues.length;
				for(var index:int = 0; index < len; index++)
				{
					var dObj:Object = obj.dialogues[index];
					var dialogue:DialogueVO = new DialogueVO();
					dialogue.buildFromObject(dObj);
					dialogues.addItem(dialogue);
				}
			}
		}
	}
}