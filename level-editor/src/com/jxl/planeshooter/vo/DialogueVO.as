package com.jxl.planeshooter.vo
{
	import com.jxl.planeshooter.constants.CharacterTypes;
	import com.jxl.planeshooter.constants.EmotionTypes;

	[Bindable]
	public class DialogueVO
	{
		public var characterName:String			= CharacterTypes.KAY;
		public var emotion:String 				= EmotionTypes.NORMAL;
		public var radio:Boolean				= false;
		public var audioName:String;
		public var audioFile:String;
		public var message:String				= "Hello!";
		public var advanceOnAudioEnd:Boolean 	= true;
		public var dialogueTime:int 			= NaN;
		public var autoPlay:Boolean				= true;
		
		public function DialogueVO()
		{
		}
		
		public function toObject():Object
		{
			var obj:Object 						= {};
			obj.characterName					= characterName;
			obj.emotion							= emotion;
			obj.audioName						= audioName;
			obj.audioFile						= audioFile;
			obj.message							= message;
			obj.advanceOnAudioEnd				= advanceOnAudioEnd;
			obj.autoPlay 						= autoPlay;
			obj.dialogueTime					= dialogueTime;
			obj.radio							= radio;
			return obj;
		}
		
		public function buildFromObject(obj:Object):void
		{
			characterName			= obj.characterName;
			emotion					= obj.emotion;
			audioName				= obj.audioName;
			audioFile				= obj.audioFile;
			message					= obj.message;
			advanceOnAudioEnd		= obj.advanceOnAudioEnd;
			autoPlay 				= obj.autoPlay;
			dialogueTime			= obj.dialogueTime;
			radio					= obj.radio;
		}
	}
}