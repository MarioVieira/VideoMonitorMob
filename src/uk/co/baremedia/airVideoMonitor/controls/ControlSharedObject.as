package uk.co.baremedia.airVideoMonitor.controls
{
	import flash.net.SharedObject;
	
	import org.as3.mvcsInjector.utils.Tracer;
	
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class ControlSharedObject
	{
		protected var _sharedObject	:SharedObject;
		
		public static var LANGUAGE_BUNLDE  :String = "languageBundle";
		
		public function ControlSharedObject(appUID:String)
		{
			setup(appUID);
			updateLanguage(); 
			UtilsResources.bundleChange.add(onLanguageBundleChange)
		}
		
		private function onLanguageBundleChange():void
		{
			//Tracer.log(this, "language: "+UtilsResources.bundleName);
			language = UtilsResources.bundleName;
		}
		
		private function updateLanguage():void
		{
			var tmpLanguage:String = language;
			//Tracer.log(this, "tmpLanguage - tmpLanguage: "+tmpLanguage + "null: "+(tmpLanguage != "null" && tmpLanguage != null) );
			if(tmpLanguage && tmpLanguage != "" && language != "null")
			{
				//Tracer.log(this, "tmpLanguage - UPDATE");
				UtilsResources.bundleName = language;
			}
		}
		
		public function setup(appUID:String):void
		{
			_sharedObject = SharedObject.getLocal(appUID);
		}
		
		public function set language(value:String):void
		{
			_sharedObject.data[LANGUAGE_BUNLDE] = value; 
			flush();
		}
		
		public function get language():String
		{
			return _sharedObject.data[LANGUAGE_BUNLDE];
		}
		protected function flush():void
		{
			_sharedObject.flush();
		}
	}
}