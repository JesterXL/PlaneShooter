package com.jxl.planeshooter.views.levelpreviewviews
{
	import com.jxl.planeshooter.vo.EnemyVO;
	import com.jxl.planeshooter.vo.EventVO;
	
	import flash.display.Graphics;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	
	public class EnemyView extends UIComponent
	{
		private var _enemy:EnemyVO;
		
		public function get enemy():EnemyVO { return _enemy; }
		public function set enemy(value:EnemyVO):void
		{
			if(_enemy)
			{
				_enemy.removeEventListener("xOrYChanged", onXorYChanged);
			}
			_enemy = value;
			if(_enemy)
			{
				_enemy.addEventListener("xOrYChanged", onXorYChanged);
			}
		}
		
		public function EnemyView()
		{
			super();
			
			width = 10;
			height = 10;
		}
		
		private function onXorYChanged(event:Event):void
		{
			x = _enemy.x;
			y = _enemy.y;
		}
		
		protected override function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0x000000);
			g.drawRect(0, 0, 10, 10);
			g.endFill();
		}
	}
}