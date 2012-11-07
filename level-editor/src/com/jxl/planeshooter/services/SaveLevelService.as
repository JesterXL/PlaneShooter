package com.jxl.planeshooter.services
{
	import com.jxl.planeshooter.events.SaveLevelServiceEvent;
	import com.jxl.planeshooter.vo.LevelVO;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	[Event(name="saveSuccess", type="com.jxl.planeshooter.events.SaveLevelServiceEvent")]
	[Event(name="saveError", type="com.jxl.planeshooter.events.SaveLevelServiceEvent")]
	public class SaveLevelService extends EventDispatcher
	{
		
		private var file:File;
		private var stream:FileStream;
		private var str:String;
		
		public function SaveLevelService()
		{
			super();
		}
		
		public function saveLevel(level:LevelVO):void
		{
			try
			{
				var obj:Object = level.toObject();
			}
			catch(err:Error)
			{
				Debug.error("SaveLevelService::saveLevel, error in converting LevelVO to Object: " + err);
				dispatchEvent(new SaveLevelServiceEvent(SaveLevelServiceEvent.SAVE_ERROR));
				return;
			}
			
			try
			{
				str = JSON.stringify(obj);
			}
			catch(err:Error)
			{
				Debug.error("SaveLevelService::saveLevel, error in serializing JSON string: " + err);
				dispatchEvent(new SaveLevelServiceEvent(SaveLevelServiceEvent.SAVE_ERROR));
				return;
			}
			
			
			
			if(file == null)
			{
				file = new File();
				file.addEventListener(IOErrorEvent.IO_ERROR, onFileError);
				file.addEventListener(Event.SELECT, onFileSelect);
			}
			
			try
			{
				file.browseForSave("Save");
			}
			catch(err:Error)
			{
				Debug.error("SaveLevelService::err: " + err);
			}
		}
		
		private function onFileError(event:IOErrorEvent):void
		{
			Debug.error("SaveLevelService::onFileError: " + event);
		}
		
		private function onFileSelect(event:Event):void
		{
			if(stream == null)
			{
				stream = new FileStream();
			}
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(str);
			stream.close();
			dispatchEvent(new SaveLevelServiceEvent(SaveLevelServiceEvent.SAVE_SUCCESS));
		}
	}
}