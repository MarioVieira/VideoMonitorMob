package uk.co.baremedia.airVideoMonitor.utils
{
	import mx.collections.ArrayCollection;
	
	import uk.co.baremedia.airVideoMonitor.enums.EnumsLanguage;
	import uk.co.baremedia.gnomo.utils.UtilsResources;
	
	public class UtilsLanguage
	{
		public function UtilsLanguage()
		{
			
		}
		
		public static function get languages():ArrayCollection
		{
			return new ArrayCollection( [{label:UtilsResources.getKey(EnumsLanguage.ENGLISH), key:"en_US"},
										 {label:UtilsResources.getKey(EnumsLanguage.ITALIAN), key:"it_IT"},
										 {label:UtilsResources.getKey(EnumsLanguage.SPANISH), key:"es_ES"},
										 {label:UtilsResources.getKey(EnumsLanguage.PORTUGUESE), key:"pt_BR" }] );
		}
	}
}