package com.jxl.planeshooter.views.levelpreviewviews
{
	import com.jxl.planeshooter.vo.EnemyVO;
	import com.jxl.planeshooter.vo.EventVO;
	import com.jxl.planeshooter.vo.LevelVO;
	
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	public class EnemyTimelineView extends UIComponent
	{
		
		private var _level:LevelVO;
		private var levelDirty:Boolean = false;
		private var timeDirty:Boolean = false;
		private var _currentTime:Number = 1;
		private var playhead:Shape;
		private var loaderPool:Array = [];
		private var loadersHolder:UIComponent;
		private var sizeChanged:Boolean = false;
		
		private var lastWidth:Number = width;
		private var lastHeight:Number = height;
		
		public override function set width(value:Number):void
		{
			if(lastWidth != value)
			{
				sizeChanged = true;
				invalidateDisplayList();
			}
			lastWidth = value;
			super.width = value;
		}
		
		public override function set height(value:Number):void
		{
			if(lastHeight != value)
			{
				sizeChanged = true;
				invalidateDisplayList();
			}
			lastHeight = value;
			super.height = value;
		}
		
		[Bindable]
		public function get level():LevelVO { return _level; }
		public function set level(value:LevelVO):void
		{
			if(_level != null)
			{
				_level.events.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onChanged);
			}
			_level = value;
			if(_level)
			{
				_level.events.addEventListener(CollectionEvent.COLLECTION_CHANGE, onChanged);
			}
			levelDirty = true;
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
			}
			timeDirty = true;
			invalidateProperties();
		}
		
		public function EnemyTimelineView()
		{
			super();
			
			width = 320;
			height = 240;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			loadersHolder = new UIComponent();
			addChild(loadersHolder);
			
			playhead = new Shape();
			addChild(playhead);
			
			addEventListener("widthChanged", onWidthHeightChanged);
			addEventListener("heightChanged", onWidthHeightChanged);
		}
		
		private function onChanged(event:CollectionEvent):void
		{
			redraw();
		}
		
		protected override function commitProperties():void
		{
			super.commitProperties();
			
			if(levelDirty)
			{
				timeDirty = false;
				levelDirty = false;
				redraw();
			}
			
			if(timeDirty)
			{
				timeDirty = false;
				redrawPlayhead();
			}
		}
		
		protected override function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			if(sizeChanged)
			{
				sizeChanged = false;
				redraw();
			}
		}
		
		private function onWidthHeightChanged(event:Event):void
		{
			sizeChanged = true;
			invalidateDisplayList();
		}
		
		public function redraw():void
		{
			clearLoaders();
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(0, 0x000000);
			g.drawRect(0, 0, width, height);
			
			var startTime:Number = 0;
			var len:int;
			if(level && level.events)
			{
				len = level.events.length;
			}
			else
			{
				len = 0;
			}
			var event:EventVO;
			var eventsLen:int = 0;
			for(var index:int = 0; index < len; index++)
			{
				event = level.events[index];
				if(event is EnemyVO)
				{
					eventsLen++;
				}
			}
			
			var targetX:Number;
			var targetWidth:Number = 10;
			var targetHeight:Number = Math.min(10, height / eventsLen);
			var startY:Number = 0;
			for(index = 0; index < len; index++)
			{
				event = level.events[index];
				if(event is EnemyVO)
				{
					var enemy:EnemyVO = event as EnemyVO;
					targetX = enemy.when / level.totalTime * width;
					//g.moveTo(targetX, startY);
					//g.lineStyle(0, 0x000000);
					//g.drawRect(targetX, startY, targetWidth, targetHeight);
					
					var loader:Loader = getLoader();
					loadersHolder.addChild(loader);
					loader.load(new URLRequest("assets/images/" + enemy.type + ".png"));
					loader.x = targetX;
					loader.y = startY;
					
					startY += targetHeight;
				}
			}
			
			g.endFill();
			
			g = playhead.graphics;
			g.clear();
			g.lineStyle(2, 0x00FF00, .8);
			g.lineTo(0, height);
			g.endFill();
			
			redrawPlayhead();
		}
		
		private function clearLoaders():void
		{
			var len:int = loadersHolder.numChildren;
			while(len--)
			{
				var loader:Loader = loadersHolder.removeChildAt(len) as Loader;
				try
				{
					loader.close();
				} 
				catch(error:Error) 
				{
				}
				loaderPool.push(loader);
			}
		}
		
		private function redrawPlayhead():void
		{
			if(level)
			{
				playhead.x = currentTime / level.totalTime * width;
			}
			else
			{
				playhead.x = 0;
			}
		}
		
		private function getLoader():Loader
		{
			if(loaderPool.length > 0)
			{
				return loaderPool.pop() as Loader;
			}
			else
			{
				return new Loader();
			}
		}
		
	}
}