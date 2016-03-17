package com.airmyth.net.as3network.event
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class UploadEventDispatcher extends EventDispatcher
	{
		private static var _instance:UploadEventDispatcher;
		
		public function UploadEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance():UploadEventDispatcher
		{
			if(!_instance)
				_instance = new UploadEventDispatcher();
			
			return _instance;
		}
	}
}