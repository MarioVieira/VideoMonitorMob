package uk.co.baremedia.airVideoMonitor.vo
{
	
	public class VOHelpItem
	{
		public var url		:String;
		public var body		:String;
		public var type		:int;
		public var subject	:String;
		public var label	:String;
		
		public function VOHelpItem(type:int, label:String, subject:String, body:String, url:String)
		{
			this.type = type;
			this.label = label;
			this.subject = subject;
			this.url = url;
			this.body = body;
		}
	}
}