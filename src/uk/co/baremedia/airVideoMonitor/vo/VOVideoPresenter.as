package uk.co.baremedia.airVideoMonitor.vo
{
	import mx.core.UIComponent;
	
	import uk.co.baremedia.airVideoMonitor.interfaces.IVideoPresenter;

	[Bindable]
	public class VOVideoPresenter
	{
		public var presenter  :IVideoPresenter;
		public var constainer :UIComponent;
		public var screenIndex:int;
		
		public function VOVideoPresenter(presenter:IVideoPresenter, constainer:UIComponent, screenIndex:int) 
		{
			this.presenter  = presenter;
			this.constainer = constainer;
			this.screenIndex= screenIndex;
		}
	}
}