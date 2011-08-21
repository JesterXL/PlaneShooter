package 
{
	import com.jxl.debug.Colors;
	import com.jxl.debug.DebugMaxItemRenderer;
	import com.jxl.debug.Message;
	import com.jxl.debug.MessageType;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.CollectionEvent;
	import mx.events.ItemClickEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.List;
	import spark.components.TabBar;
	
	public class Debug extends UIComponent
	{
		public static const USER_ALL:String 				= "All";
		public static var DEBUG_DISABLED:Boolean 			= false;
		public static const USER_DEVELOPER_B:String 		= "DeveloperB";
		
		private static var NAMES:Dictionary;
		private static const ALLOWED_USERS:Array 			= [USER_DEVELOPER_B, USER_ALL];
		
		private static var inst:Debug;
		private static var backlog:ArrayCollection 			= new ArrayCollection();
		private static var constrctured:Boolean 			= classConstruct();
		
		private static const MARGIN:Number 					= 4;
		
		
		private static const HEADER_TEXT:String 			= "---------------------";
		
		private var copyButton:Button;
		private var scrollCheckBox:CheckBox;
		private var list:List;
		private var background:Sprite;
		private var closeButton:Button;
		private var tabs:TabBar;
		
		private var messages:ArrayCollection;
		private var autoScrollDirty:Boolean 				= false;
		private var clearButton:Button;
		private var dragging:Boolean 						= false;
		private var scrollTimer:Timer;
		private var _autoScroll:Boolean 					= true;
		
		public function Debug() : void
		{
			super();
			init();
		}
		
		private function init():void
		{
			inst = this;
			setStyle("color", 3355443);
			
			// TODO/FIXME
			/*
			var debugging:Boolean = true;
			if (debugging)
			{
				DEBUG_DISABLED = false;
			}
			else
			{
				DEBUG_DISABLED = true;
			}
			
			if (DEBUG_DISABLED)
			{
				return;
			}
			*/
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			var bLog:* = backlog.source.concat();
			bLog.sortOn("date", Array.NUMERIC);
			messages = new ArrayCollection(bLog);
			messages.addEventListener(CollectionEvent.COLLECTION_CHANGE, onMessagesChanged);
			backlog.removeAll();
			backlog = null;
		}
		
		public function fatal(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(o);
			messages.addItem(new Message(MessageType.FATAL, o, user));
		}
		
		public function warn(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(o);
			messages.addItem(new Message(MessageType.WARN, o, user));
		}
		
		public function error(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(o);
			messages.addItem(new Message(MessageType.ERROR, o, user));
		}
		
		private function onMouseMove(event:MouseEvent) : void
		{
			event.updateAfterEvent();
		}
		
		private function onItemClick(event:ItemClickEvent) : void
		{
			switch(event.item)
			{
				case NAMES[MessageType.LOG]:
				{
					filterMessages(MessageType.LOG);
					list.setStyle("borderColor", Colors.LOG);
					break;
				}
				case NAMES[MessageType.DEBUG]:
				{
					filterMessages(MessageType.DEBUG);
					list.setStyle("borderColor", Colors.DEBUG);
					break;
				}
				case NAMES[MessageType.INFO]:
				{
					filterMessages(MessageType.INFO);
					list.setStyle("borderColor", Colors.INFO);
					break;
				}
				case NAMES[MessageType.WARN]:
				{
					filterMessages(MessageType.WARN);
					list.setStyle("borderColor", Colors.WARN);
					break;
				}
				case NAMES[MessageType.ERROR]:
				{
					filterMessages(MessageType.ERROR);
					list.setStyle("borderColor", Colors.ERROR);
					break;
				}
				case NAMES[MessageType.FATAL]:
				{
					filterMessages(MessageType.FATAL);
					list.setStyle("borderColor", Colors.FATAL);
					break;
				}
				default:
				{
					break;
				}
			}
		}
		
		override protected function createChildren() : void
		{
			super.createChildren();
			
			background = new Sprite();
			addChild(background);
			background.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			background.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			background.buttonMode = true;
			
			tabs = new TabBar();
			tabs.includeInLayout = false;
			addChild(tabs);
			tabs.dataProvider = new ArrayCollection([NAMES[MessageType.LOG], NAMES[MessageType.DEBUG], NAMES[MessageType.INFO], NAMES[MessageType.WARN], NAMES[MessageType.ERROR], NAMES[MessageType.FATAL]]);
			tabs.addEventListener(ItemClickEvent.ITEM_CLICK, onItemClick);
			tabs.height = 22;
			tabs.setStyle("tabWidth", 70);
			
			list = new List();
			list.includeInLayout = false;
			addChild(list);
			
			list.dataProvider = messages;
			//list.variableRowHeight = true;
			//list.wordWrap = true;
			list.labelField = "content";
			list.allowMultipleSelection = true;
			list.itemRenderer = new ClassFactory(DebugMaxItemRenderer);
			list.setStyle("borderStyle", "solid");
			list.setStyle("borderThickness", 4);
		
			clearButton = new Button();
			clearButton.includeInLayout = false;
			addChild(clearButton);
			clearButton.addEventListener(MouseEvent.CLICK, onClear);
			clearButton.height = 22;
			clearButton.label = "Clear";
			
			copyButton = new Button();
			copyButton.includeInLayout = false;
			addChild(copyButton);
			copyButton.addEventListener(MouseEvent.CLICK, onCopy);
			copyButton.height = 22;
			copyButton.width = 120;
			copyButton.label = "Copy to Clipboard";
			
			scrollCheckBox = new CheckBox();
			scrollCheckBox.includeInLayout = false;
			addChild(scrollCheckBox);
			scrollCheckBox.label = "auto-scroll";
			scrollCheckBox.selected = autoScroll;
			scrollCheckBox.addEventListener(Event.CHANGE, onToggleAutoScroll);
			scrollCheckBox.setActualSize(100, 22);
			scrollCheckBox.styleName = "checkBoxStyle";
			
			closeButton = new Button();
			closeButton.includeInLayout = false;
			addChild(closeButton);
			closeButton.addEventListener(MouseEvent.CLICK, onClose);
			closeButton.setActualSize(16, 16);
			
			var filter:* = new DropShadowFilter(3, 45, 3355443, 0.7, 4, 4, 1, 1, false, false, false);
			filters = [filter];
			
			callLater(scrollIt);
		}
		
		private function onTick(event:TimerEvent) : void
		{
			scrollIt();
			if (_autoScroll == false)
			{
				destroyScrollTimer();
			}
			if (list == null)
			{
				destroyScrollTimer();
			}
			// TODO: totally lost that blogpost on what the new property name is...
			if (list.scroller.viewport.verticalScrollPosition == maxVerticalScrollPosition)
			{
				destroyScrollTimer();
			}
		}
		
		private function destroyScrollTimer() : void
		{
			if (scrollTimer)
			{
				scrollTimer.stop();
				scrollTimer.removeEventListener(TimerEvent.TIMER, onTick);
				scrollTimer = null;
			}
		}
		
		private function onAddedToStage(event:Event) : void
		{
			var so:SharedObject;
			var event:* = event;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			try
			{
				so = SharedObject.getLocal("DebugMax_position");
				if (so != null)
				{
					if (so.data.pos != null)
					{
						if (so.data.pos.x != undefined && so.data.pos.y != undefined)
						{
							move(so.data.pos.x, so.data.pos.y);
						}
					}
				}
			}
			catch (err:Error)
			{
			}
		}
		
		public function info(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(o);
			messages.addItem(new Message(MessageType.INFO, o, user));
		}
		
		public function fatalHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			messages.addItem(new Message(MessageType.FATAL, HEADER_TEXT, user));
		}
		
		public function errorHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			messages.addItem(new Message(MessageType.ERROR, HEADER_TEXT, user));
		}
		
		public function set autoScroll(scroll:Boolean) : void
		{
			_autoScroll = scroll;
			autoScrollDirty = true;
			invalidateProperties();
		}
		
		public function warnHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			messages.addItem(new Message(MessageType.WARN, HEADER_TEXT, user));
		}
		
		private function onClear(event:MouseEvent) : void
		{
			messages.removeAll();
		}
		
		public function debugHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			messages.addItem(new Message(MessageType.DEBUG, HEADER_TEXT, user));
		}
		
		private function onMouseUp(event:MouseEvent) : void
		{
			if (dragging)
			{
				dragging = false;
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				stopDrag();
				event.updateAfterEvent();
				var so:SharedObject = SharedObject.getLocal("DebugMax_position");
				so.data.pos = {x:x, y:y};
				var result:String = so.flush();
			}
		}
		
		public function log(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(o);
			messages.addItem(new Message(MessageType.LOG, o, user));
		}
		
		private function onMouseDown(event:MouseEvent) : void
		{
			if (dragging == false)
			{
				dragging = true;
				this.startDrag();
				this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		override protected function commitProperties() : void
		{
			super.commitProperties();
			if (autoScrollDirty)
			{
				autoScrollDirty = false;
				scrollCheckBox.selected = _autoScroll;
			}
		}
		
		private function onToggleAutoScroll(event:Event) : void
		{
			_autoScroll = scrollCheckBox.selected;
		}
		
		public function debug(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(o);
			messages.addItem(new Message(MessageType.DEBUG, o, user));
		}
		
		private function scrollIt() : void
		{
			if (_autoScroll)
			{
				if (list)
				{
					list.scroller.viewport.verticalScrollPosition = maxVerticalScrollPosition;
				}
			}
		}
		
		private function get maxVerticalScrollPosition():int
		{
			return list.scroller.viewport.contentHeight - list.scroller.viewport.height;
		}
		
		private function onClose(event:MouseEvent) : void
		{
			var messages:Array;
			inst = null;
			if (messages)
			{
				messages = messages.source.concat();
				backlog = new ArrayCollection(messages);
				messages.removeAll();
				messages = null;
			}
			PopUpManager.removePopUp(this);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		public function infoHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			messages.addItem(new Message(MessageType.INFO, HEADER_TEXT, user));
		}
		
		public function get autoScroll() : Boolean
		{
			return _autoScroll;
		}
		
		override protected function measure() : void
		{
			measuredMinWidth = 120;
			measuredMinHeight = 120;
			measuredWidth = 540;
			measuredHeight = 400;
		}
		
		private function filterMessages(type:uint) : void
		{
			var type:uint = type;
			switch(type)
			{
				case MessageType.LOG:
				{
					messages.filterFunction = null;
					break;
				}
				case MessageType.DEBUG:
				{
					messages.filterFunction = function (message:Message) : Boolean
					{
						if (message.type >= MessageType.DEBUG)
						{
							return true;
						}
						return false;
					};
					break;
				}
				case MessageType.INFO:
				{
					messages.filterFunction = function (message:Message) : Boolean
					{
						if (message.type >= MessageType.INFO)
						{
							return true;
						}
						return false;
					};
					break;
				}
				case MessageType.WARN:
				{
					messages.filterFunction = function (message:Message) : Boolean
					{
						if (message.type >= MessageType.WARN)
						{
							return true;
						}
						return false;
					};
					break;
				}
				case MessageType.ERROR:
				{
					messages.filterFunction = function (message:Message) : Boolean
					{
						if (message.type >= MessageType.ERROR)
						{
							return true;
						}
						return false;
					};
					break;
				}
				case MessageType.FATAL:
				{
					messages.filterFunction = function (message:Message) : Boolean
					{
						if (message.type >= MessageType.FATAL)
						{
							return true;
						}
						return false;
					};
					break;
				}
			}
			messages.refresh();
		}
		
		private function onMessagesChanged(event:CollectionEvent) : void
		{
			scrollIt();
			destroyScrollTimer();
			if (scrollTimer == null)
			{
				scrollTimer = new Timer(500);
				scrollTimer.addEventListener(TimerEvent.TIMER, onTick, false, 0, true);
				scrollTimer.start();
			}
		}
		
		public function logHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			messages.addItem(new Message(MessageType.LOG, HEADER_TEXT, user));
		}
		
		private function onRemovedFromStage(event:Event) : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function onCopy(event:MouseEvent) : void
		{
			var message:Message;
			var str:String;
			var len:int = messages.length;
			for(var index:int = 0; index < len; index++)
			{
				
				message = messages[index] as Message;
				str = str + (NAMES[message.type] + "  " + message.content + "\n");
			}
			try
			{
				System.setClipboard(str);
			}
			catch (err:Error)
			{
				Debug.error(Debug, "onCopy, Failed to to copy to clipboard.");
				Debug.error(Debug, err.toString());
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			background.graphics.clear();
			background.graphics.beginFill(3355443, 0.8);
			background.graphics.drawRoundRect(0, 0, width, height, 6, 6);
			background.graphics.endFill();
			
			closeButton.move(width - (closeButton.width + MARGIN), 2);
			tabs.move(MARGIN, MARGIN);
			tabs.setActualSize(width - MARGIN * 2, tabs.height);
			scrollCheckBox.move(width - (scrollCheckBox.width + MARGIN), height - (scrollCheckBox.height + MARGIN));
			clearButton.move(MARGIN, height - (clearButton.height + MARGIN));
			clearButton.setActualSize(width - scrollCheckBox.width - copyButton.width - MARGIN * 5, clearButton.height);
			copyButton.move(clearButton.x + clearButton.width + MARGIN, clearButton.y);
			list.move(tabs.x, tabs.y + tabs.height);
			list.setActualSize(width - MARGIN * 2, height - clearButton.height - MARGIN * 2 - list.y);
		}
		
		public static function debugHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			if (inst)
			{
				inst.debugHeader(user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.DEBUG, HEADER_TEXT, user));
			}
		}
		
		public static function log(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace("Log:::" + o);
			if (inst)
			{
				inst.log(o, user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.LOG, o, user));
			}
		}
		
		public static function warn(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace("Warn:::" + o);
			if (inst)
			{
				inst.warn(o, user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.WARN, o, user));
			}
		}
		
		public static function fatalHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			if (inst)
			{
				inst.fatalHeader(user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.FATAL, HEADER_TEXT, user));
			}
		}
		
		public static function fatal(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace("Fatal:::" + o);
			if (inst)
			{
				inst.fatal(o, user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.FATAL, o, user));
			}
		}
		
		private static function classConstruct() : Boolean
		{
			NAMES = new Dictionary();
			NAMES[MessageType.LOG] = "Log";
			NAMES[MessageType.DEBUG] = "Debug";
			NAMES[MessageType.INFO] = "Info";
			NAMES[MessageType.WARN] = "Warn";
			NAMES[MessageType.ERROR] = "Error";
			NAMES[MessageType.FATAL] = "Fatal";
			return true;
		}
		
		public static function error(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace("Error:::" + o);
			if (inst)
			{
				inst.error(o, user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.ERROR, o, user));
			}
		}
		
		public static function debug(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace("Debug:::" + o);
			if (inst)
			{
				inst.debug(o, user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.DEBUG, o, user));
			}
		}
		
		public static function infoHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			if (inst)
			{
				inst.infoHeader(user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.INFO, HEADER_TEXT, user));
			}
		}
		
		public static function info(o:*, user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace("Info:::" + o);
			if (inst)
			{
				inst.info(o, user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.INFO, o, user));
			}
		}
		
		public static function warnHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			if (inst)
			{
				inst.warnHeader(user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.WARN, HEADER_TEXT, user));
			}
		}
		
		public static function errorHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			if (inst)
			{
				inst.errorHeader(user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.ERROR, HEADER_TEXT, user));
			}
		}
		
		public static function logHeader(user:String = "All") : void
		{
			if (DEBUG_DISABLED)
			{
				return;
			}
			if (ALLOWED_USERS.indexOf(user) < 0)
			{
				return;
			}
			trace(HEADER_TEXT);
			if (inst)
			{
				inst.logHeader(user);
			}
			else
			{
				backlog.addItem(new Message(MessageType.LOG, HEADER_TEXT, user));
			}
		}
		
	}
}
