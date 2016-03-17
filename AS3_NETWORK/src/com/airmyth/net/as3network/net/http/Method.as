package com.airmyth.net.as3network.net.http
{
	import com.airmyth.IDestroy;
	import com.airmyth.net.as3network.model.Session;
	
	import flash.events.EventDispatcher;
	
	/**
	 * 回调成功，返回方法调用结果 
	 */	
	[Event(name="result", type="com.airmyth.net.as3network.event.NetResultEvent")]
	/**
	 * 方法调用失败 
	 */	
	[Event(name="fault", type="com.airmyth.net.as3network.event.NetFaultEvent")]
	
	/**
	 * 函数 
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class Method extends EventDispatcher implements IDestroy
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
		public function send(params:Array=null, resultHandler:Function=null, faultHandler:Function=null, paramTypes:Array=null, requestHeads:Object=null):Session
		{
			return _sendFun(_name, params, resultHandler, faultHandler, paramTypes, requestHeads);
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

		public function destroy():void
		{
			_sendFun = null;
		}
		
	}
}