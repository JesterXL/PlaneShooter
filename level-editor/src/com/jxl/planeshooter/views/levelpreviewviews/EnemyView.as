package com.jxl.planeshooter.views.levelpreviewviews
{
	import com.jxl.planeshooter.vo.EnemyVO;
	import com.jxl.planeshooter.vo.EventVO;
	
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.core.UIComponent;
	
	import spark.components.Image;
	
	public class EnemyView extends UIComponent
	{
		private var _enemy:EnemyVO;
		private var iconImage:Loader;
		private var dragging:Boolean = false;
		
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
			updateIcon();
		}
		
		public function EnemyView()
		{
			super();
			
			width = 10;
			height = 10;
		}
		
		private function onXorYChanged(event:Event):void
		{
			if(dragging == false)
			{
				x = _enemy.x;
				y = _enemy.y;
			}
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			iconImage = new Loader();
			addChild(iconImage);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected override function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0x000000, 0);
			g.drawRect(0, 0, 10, 10);
			g.endFill();
		}
		
		private function updateIcon():void
		{
			if(_enemy && _enemy.type)
			{
				iconImage.load(new URLRequest("assets/images/" + _enemy.type + ".png"));
			}
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			dragging = true;
			this.startDrag(false);
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			event.updateAfterEvent();
			_enemy.move(x, y);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			dragging = false;
			stopDrag();
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
	}
}