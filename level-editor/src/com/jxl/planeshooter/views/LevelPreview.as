package com.jxl.planeshooter.views
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Expo;
	import com.jxl.planeshooter.views.levelpreviewviews.EnemyView;
	import com.jxl.planeshooter.vo.EnemyVO;
	import com.jxl.planeshooter.vo.EventVO;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	public class LevelPreview extends UIComponent
	{
		
		private var _events:ArrayCollection;
		private var eventsDirty:Boolean = false;
		
		private var backgroundShape:Shape;
		private var childrenSprite:UIComponent;
		private var pool:Array = [];
		private var _startTime:Number = 0;
		private var _endTime:Number = 2;
		private var timeDirty:Boolean = false;
		private var _currentTime:Number = 1;
		
		[Bindable]
		public function get events():ArrayCollection { return _events; }
		public function set events(value:ArrayCollection):void
		{
			if(_events != null)
			{
				_events.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onChanged);
			}
			_events = value;
			if(_events)
			{
				_events.addEventListener(CollectionEvent.COLLECTION_CHANGE, onChanged);
			}
			eventsDirty = true;
			invalidateProperties();
		}
		
		[Bindable]
		public function get startTime():Number { return _startTime; }
		public function set startTime(value:Number):void
		{
			_startTime = value;
			timeDirty = true;
			invalidateProperties();
		}
		
		[Bindable]
		public function get endTime():Number { return _endTime; }
		public function set endTime(value:Number):void
		{
			_endTime = value;
			timeDirty = true;
			invalidateProperties();
		}
		
		[Bindable]
		public function get currentTime():Number { return _currentTime; }
		public function set currentTime(value:Number):void
		{
			_currentTime = value;
			if(isNaN(_currentTime) == true)
			{
				_currentTime = 0;
				_startTime = 0;
				_endTime = 1;
			}
			else
			{
				_startTime = _currentTime;
				_endTime = _currentTime + 1;
			}
			
			timeDirty = true;
			invalidateProperties();
		}
		
		public function LevelPreview()
		{
			super();
			
			width = 320;
			height = 640;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			backgroundShape = new Shape();
			addChild(backgroundShape);
			
			childrenSprite = new UIComponent();
			addChild(childrenSprite);
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if(eventsDirty)
			{
				eventsDirty = false;
				timeDirty = false;
				redraw();
			}
			
			if(timeDirty)
			{
				timeDirty = false;
				refresh();
			}
		}
		
		protected override function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			var g:Graphics = backgroundShape.graphics;
			g.clear();
			g.lineStyle(2, 0x000000);
			g.beginFill(0xFFFFFF);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			
		}
		
		private function onChanged(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.REFRESH:
					refresh();
					break;
				
				case CollectionEventKind.ADD:
				case CollectionEventKind.REMOVE:
					redraw();
					break;
			}
		}
		
		private function redraw():void
		{
			clear();
			
			var len:int = events.length;
			for(var index:int = 0; index < len; index++)
			{
				var event:EventVO = events[index];
				if(event is EnemyVO)
				{
					var enemyView:EnemyView = getEnemyView();
					childrenSprite.addChild(enemyView);
					var enemyVO:EnemyVO = event as EnemyVO;
					enemyView.enemy = enemyVO;
					enemyView.x = enemyVO.x;
					enemyView.y = enemyVO.y;
					enemyView.visible = false;
					enemyView.alpha = 0;
				}
			}
			
			refresh();
		}
		
		private function refresh():void
		{
			var len:int = childrenSprite.numChildren;
			var diff:Number = _endTime - _startTime;
			while(len--)
			{
				var view:EnemyView = childrenSprite.getChildAt(len) as EnemyView;
				var enemy:EnemyVO = view.enemy;
				if(_currentTime + .1 > enemy.when && _currentTime < enemy.when + diff + .1)
				{
					if(view.alpha == 0)
					{
						view.visible = true;
						var targetX:Number = view.x;
						var targetY:Number = view.y;
						view.scaleX = view.scaleY = 6;
						
						TweenLite.to(view, .5, {alpha: 1, scaleX: 1, scaleY: 1, ease: Expo.easeOut, overwrite: 0});
					}
				}
				else
				{
					//view.visible = false;
					TweenLite.to(view, .3, {alpha: 0, ease: Expo.easeOut, overwrite:1});
				}
			}
		}
		
		private function clear():void
		{
			var len:int = childrenSprite.numChildren;
			while(len--)
			{
				var enemy:EnemyView = childrenSprite.removeChildAt(len) as EnemyView;
				enemy.enemy = null;
				pool.push(enemy);
			}
		}
		
		private function getEnemyView():EnemyView
		{
			if(pool.length > 0)
			{
				return pool.pop() as EnemyView;
			}
			else
			{
				return new EnemyView();
			}
		}
		
	}
}