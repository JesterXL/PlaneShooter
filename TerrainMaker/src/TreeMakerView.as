package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	import mx.core.UIComponent;
	
	public class TreeMakerView extends UIComponent
	{

		private var depend1:Group1;
		private var depend2:Group2;
		private var depend3:Group3;
		private var depend4:Group4;
		
		
		public var treesPerCol:Number = 20;
		public var treesPerRow:Number = 80;
		public var startX:Number = 0;
		public var startY:Number = 0;
		public var WIDTH:Number = 480;
		public var HEIGHT:Number = 1280;
		public var treeWidth:Number = WIDTH / treesPerCol;
		public var treeHeight:Number = HEIGHT / treesPerRow;
		public var holder:Sprite;
		
		public function TreeMakerView()
		{
			super();
			
			width = 480;
			height = 1280;
		}
		
		protected override function createChildren():void
		{
			super.createChildren();
			
			holder = new Sprite();
			addChild(holder);
		}
		
		public function redrawTrees():void
		{
			clearTrees();
			
			startX = 0;
			startY = 0;
			
			for(var row:int = 0; row < treesPerRow; row++)
			{
				for(var col:int = 0; col < treesPerCol; col++)
				{
					var randomGroup:int = Math.floor(Math.random() * 4) + 1;
					//trace(randomGroup);
					var groupName:String = "Group" + randomGroup;
					var clazz:Class = getDefinitionByName(groupName) as Class;
					var tree:Sprite = new clazz();
					holder.addChild(tree);
					var randomOffset:Number = 10;
					var offsetX:Number = Math.round(randomOffset * Math.random()) - Math.round(randomOffset * Math.random());
					var offsetY:Number = Math.round(randomOffset * Math.random()) - Math.round(randomOffset * Math.random());
					tree.x = startX + offsetX;
					tree.y = startY + offsetY;
					startX += treeWidth;
				}
				startX = 0;
				startY += treeHeight;
			}
		}
		
		private function clearTrees():void
		{
			var len:int = holder.numChildren;
			while(len--)
			{
				holder.removeChildAt(len);
			}
		}
		
		public function makeBitmapData():BitmapData
		{
			var bitmapData:BitmapData = new BitmapData(480, 1280, true, 0);
			bitmapData.draw(holder);
			return bitmapData;
		}
	}
}