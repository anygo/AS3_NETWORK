package cn.as3network.event
{
	import cn.as3network.model.DataVo;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * 通信失败 事件 
	 * @author 破晓
	 * 
	 */	
	public class FaultEvent extends Event
	{
		/**调用后台方法异常时触发*/
		public static const RESULT_EVENT:String = "A2JFailEvent";
		
		private var _message:String;
		private var _service:String;
		private var _methodName:String;
		
		/**
		 * 构造函数 
		 * @param data
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function FaultEvent(data:*, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(RESULT_EVENT, bubbles, cancelable);
			
			if(data is DataVo)
			{
				_message = data.errorMessage;
				_service = data.serviceName;
				_methodName = data.methodName;
			}
			else if(data is IOErrorEvent)
			{
				var error:IOErrorEvent = data as IOErrorEvent;
				_message = error.toString();
			}
			else if(data is SecurityErrorEvent)
			{
				var se:SecurityErrorEvent = data as SecurityErrorEvent;
				_message = se.toString();
			}
			else
				_message = data + "";
		}

		/**
		 * 异常信息 
		 * @return 
		 * 
		 */		
		public function get message():String
		{
			return _message;
		}

		/**
		 * 后台服务名称 
		 * @return 
		 * 
		 */		
		public function get service():String
		{
			return _service;
		}

		/**
		 * 调用的后台函数名称 
		 * @return 
		 * 
		 */		
		public function get methodName():String
		{
			return _methodName;
		}


	}
}