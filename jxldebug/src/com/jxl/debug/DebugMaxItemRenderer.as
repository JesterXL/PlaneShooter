package com.jxl.debug
{
	
	import spark.components.Label;
	import spark.components.supportClasses.ItemRenderer;

    public class DebugMaxItemRenderer extends ItemRenderer
    {
		private static const MARGIN:Number = 4;
		
        private var dataDirty:Boolean = false;
        private var _data:Object;
		
        

        public function DebugMaxItemRenderer()
        {
			super();
		}

        override protected function commitProperties() : void
        {
            super.commitProperties();
            if (dataDirty)
            {
                dataDirty = false;
				var message:Message = _data as Message;
                switch(message.type)
                {
                    case MessageType.LOG:
                    {
                        break;
                    }
                    case MessageType.DEBUG:
                    {
                        break;
                    }
                    case MessageType.INFO:
                    {
                        break;
                    }
                    case MessageType.WARN:
                    {
                        break;
                    }
                    case MessageType.ERROR:
                    {
                        break;
                    }
                    case MessageType.FATAL:
                    {
                        break;
                    }
                    default:
                    {
                        break;
                    }
                }
            }
		}

        override public function set data(object:Object) : void
        {
            super.data = object;
            _data = object;
            dataDirty = true;
            invalidateProperties();
		}

        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			labelDisplay.x = labelDisplay.x + labelDisplay.width + MARGIN;
			labelDisplay.setActualSize(width - labelDisplay.x, measuredHeight);
		}

        override protected function createChildren() : void
        {
            super.createChildren();
			
			labelDisplay = new Label();
            addElement(labelDisplay);
			labelDisplay.setActualSize(40, 20);
			labelDisplay.setStyle("fontFamily", "_sans");
			labelDisplay.setStyle("fontSize", 8);
		}

        override protected function measure() : void
        {
            super.measure();
            var w:Number = 0;
            var h:Number = 0;
			
            if (labelDisplay.width < 4 || labelDisplay.height < 4)
            {
				labelDisplay.width = 4;
				labelDisplay.height = 16;
            }
            if (labelDisplay.width < 4 || labelDisplay.height < 4)
            {
                labelDisplay.width = 4;
                labelDisplay.height = 16;
            }
            if (isNaN(explicitWidth))
            {
                w = w + labelDisplay.getExplicitOrMeasuredWidth();
                w = w + labelDisplay.getExplicitOrMeasuredWidth();
                measuredWidth = w;
                h = h + labelDisplay.getExplicitOrMeasuredHeight();
                h = h + labelDisplay.getExplicitOrMeasuredHeight();
            }
            else
            {
                measuredWidth = explicitWidth;
				labelDisplay.setActualSize(Math.max(explicitWidth - w - labelDisplay.width, 4), labelDisplay.height);
                measuredHeight = Math.max(labelDisplay.getExplicitOrMeasuredHeight(), labelDisplay.getExplicitOrMeasuredHeight());
            }
		}

    }
}
