package com.jxl.debug
{
    import mx.formatters.*;

    public class Message extends Object
    {
        private var _content:String;
		
        public var type:uint;
        public var user:String;
        public var date:Date;
        
		private static var dateFormatter:DateFormatter 	= new DateFormatter();
        private static var classConstructed:Boolean 	= classConstruct();

        public function Message(type:uint, content:*, user:String = "All") : void
        {
			// TODO: change to getTimer increments
            date = new Date();
            this.type = type;
            _content = content;
            this.user = user;
		}

        private function getDateString() : String
        {
            if (date)
            {
                var dateStr:String = dateFormatter.format(date);
				dateStr = dateStr + (" tz " + -1 * (date.timezoneOffset / 60));
                return dateStr;
            }
            return "";
		}

        public function get content() : String
        {
            return _content;
		}

        private static function classConstruct() : Boolean
        {
            dateFormatter.formatString = "MMM DD J:NN:SS A";
            return true;
		}

    }
}
