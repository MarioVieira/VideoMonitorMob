package uk.co.baremedia.airVideoMonitor.utils
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.as3.mvcsInjector.utils.Tracer;
	import org.osflash.signals.Signal;
	
	public class UtilsUpdater extends Signal
	{
		private var _currentBuild		:Number;
		private var _latestBuild		:Number;
		private var _updateUrl			:String;
		public var currentVersion		:String;
		public var latestVersion		:String;
		public var description			:String;
		public var fileName				:String;
		
		import flash.events.ErrorEvent;
		
		public function UtilsUpdater() 
		{
			super(Boolean);
		}
		
		public function checkForUpdate(updaterXML:String):void 
		{
			Tracer.log(this, "checkForUpdate - updaterXML: "+updaterXML);
			setApplicationVersion(); // Find the current version so we can show it below
			requestUpdater(updaterXML);
		}
		
		private function requestUpdater(updaterXML:String):void
		{
			var updateLoader:HTTPService = new HTTPService();
			updateLoader.url = updaterXML;
			updateLoader.resultFormat = "e4x";
			updateLoader.addEventListener(ResultEvent.RESULT, onResult);
			updateLoader.addEventListener(FaultEvent.FAULT, onFault);
			updateLoader.send();
		}
		
		protected function onFault(event:Event):void
		{
			Tracer.log(this, "onFault");
			dispatch(false);
		}
		
		protected function onResult(event:ResultEvent):void
		{
			var xmlResult:XML = XML(event.result);
			Tracer.log(this, "onResult - xmlResult: "+xmlResult.toXMLString());
			if(xmlResult) checkHasUpdate(xmlResult);
			else 		  dispatch(false);
		}
		
		private function checkHasUpdate(loadedUpdterXML:XML):void
		{
			var ns:Namespace = loadedUpdterXML.namespace();
			_latestBuild 	 = getBuildNumber(loadedUpdterXML,ns);
			_updateUrl	  	 = loadedUpdterXML.ns::url;
			latestVersion	 = loadedUpdterXML.ns::versionNumber;
			description		 = loadedUpdterXML.ns::description;
			fileName		 = loadedUpdterXML.ns::fileName;
			
			Tracer.log( this, "checkHasUpdate - _latestBuild: "+_latestBuild+" _currentBuild: " +_currentBuild+ " ( _currentBuild < _latestBuild ): "+( _currentBuild < _latestBuild )+" latest n: "+ Number(_latestBuild) );
			dispatch( _currentBuild < _latestBuild );
		}
		
		private function onError(event:ErrorEvent):void 
		{
			Tracer.log(this, event.toString());
			dispatch(false);
		}
		
		private function setApplicationVersion():void 
		{
			var appXML:XML 		= NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace 	= appXML.namespace();
			_currentBuild 		= getBuildNumber(appXML,ns);
			currentVersion		= appXML.ns::versionNumber;
			
			Tracer.log(this, "_appCurrentVersion: " + _currentBuild);
		}
		
		private function getBuildNumber(xml:XML, ns:Namespace):Number
		{
			return Number(xml.ns::versionNumber);
			
			//was doing with 3 digits, but little point, too late in the night
			
			//var allBeforeLastDot:String = versionNumber.substr(0, versionNumber.lastIndexOf("."));
			//var thirdDigit:String		= versionNumber.substr(versionNumber.lastIndexOf(".")+1);
			
			//Tracer.log(this, "getBuildNumber - allBeforeLastDot: "+allBeforeLastDot);
			
			
		}
		
		public function downloadUpdate():void
		{
			Tracer.log(this, "downloadUpdate: " + _updateUrl);
			navigateToURL( new URLRequest(_updateUrl) );
		}
		
		/*protected function onProgrees(event:ProgressEvent):void
		{
			var percent:Number = Math.floor(event.bytesLoaded / event.bytesTotal * 100);
			Tracer.log(this, "onProgrees: "+percent);
		}*/
	}
}

