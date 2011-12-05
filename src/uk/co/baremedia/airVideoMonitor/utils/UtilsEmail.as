package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class UtilsEmail
	{
		public static function getEmail(recipient:String, subject:String, body:String):URLRequest
		{
			var email:String = "";
			email += "mailto:";
			email+= recipient;
			email+= "?";
			email+= "subject=";
			email+= subject;
			email+= "&";
			email+= "body="
			email+=	body;
			
			return new URLRequest(email);
		}
		
		public static function sendEmail(recipient:String, subject:String, body:String):void
		{
			navigateToURL( getEmail(recipient, subject, body) );
		}
	}
}