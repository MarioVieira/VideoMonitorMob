package uk.co.baremedia.airVideoMonitor.interfaces
{
	import uk.co.baremedia.airVideoMonitor.view.components.CompVideoPresenter;

	public interface IVideoPresenterOwner
	{
		function get videoPresenterComp():CompVideoPresenter;
	}
}