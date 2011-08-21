package com.jxl.planeshooter.vo
{
	import com.jxl.planeshooter.constants.EnemyTypes;

	[Bindable]
	public class EnemyVO
	{
		public var when:int 				= 0;
		public var pause:Boolean			= false;
		public var type:String 				= EnemyTypes.PLANE;
		public var configurations:Object 	= {};
		
		public function EnemyVO()
		{
		}
		
		public function toObject():Object
		{
			var obj:Object					= {};
			obj.classType					= "enemy";
			obj.when 						= when;
			obj.pause						= pause;
			obj.type						= type;
			obj.configurations				= configurations;
			return obj;
		}
	}
}