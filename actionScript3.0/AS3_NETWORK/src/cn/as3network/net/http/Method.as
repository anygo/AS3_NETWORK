package cn.as3network.net.http
{
	import cn.as3network.IDispose;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * 回调成功，返回方法调用结果 
	 */	
	[Event(name="callServerResultEvent", type="cn.as3network.event.ResultEvent")]
	/**
	 * 方法调用失败 
	 */	
	[Event(name="callServerFailEvent", type="cn.as3network.event.FaultEvent")]
	
	/**
	 * 函数 
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class Method extends EventDispatcher implements IDispose
	{
		private var _name:String;
		private var _sendFun:Function;
		
		public function Method()
		{
			super();
		}
		
		/**
		 * 发送数据 
		 * @param methodName 函数名
		 * @param parma 参数列表
		 * 
		 */		
		public function send(...params):void
		{
			_sendFun(_name, params)
		}
		
		internal function set sendHandler(value:Function):void
		{
			_sendFun = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function dispose():void
		{
			_sendFun = null;
		}
		
	}
}