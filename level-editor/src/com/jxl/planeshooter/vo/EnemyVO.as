package com.jxl.planeshooter.vo
{
	import com.jxl.planeshooter.constants.EnemyTypes;
	
	import flash.events.Event;

	[Bindable]
	public class EnemyVO extends EventVO
	{
		public var pause:Boolean			= false;
		private var _type:String  			= EnemyTypes.PLANE;
		
		[Bindable(event="typeChanged")]
		public function get type():String { return _type; }
		public function set type(value:String):void
		{
			_type = value;
			dispatchEvent(new Event("typeChanged"));
		}
		
		public var configurations:Object 	= {};
		public var x:Number 				= 0;
		public var y:Number 				= 0;
		
		public function EnemyVO()
		{
		}
		
		public function move(newX:Number, newY:Number):void
		{
			x = newX;
			y = newY;
			dispatchEvent(new Event("xOrYChanged"));
		}
		
		public function toObject():Object
		{
			var obj:Object					= {};
			obj.classType					= "enemy";
			obj.when 						= when;
			obj.pause						= pause;
			obj.type						= type;
			obj.configurations				= configurations;
			obj.x 							= x;
			obj.y							= y;
			return obj;
		}
		
		public function buildFromObject(obj:Object):void
		{
			when 					= obj.when;
			pause					= obj.pause;
			type					= obj.type;
			configurations			= obj.configurations;
			x 						= obj.x;
			y 						= obj.y;
			
			if(isNaN(x))
				x = 0;
			
			if(isNaN(y))
				y = 0;
		}
	}
}