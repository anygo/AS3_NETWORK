package com.airmyth.net.as3network.event
{
	
	import com.airmyth.net.as3network.model.DataVo;
	import com.airmyth.net.as3network.model.Session;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.getTimer;
	
	/**
	 * 通信失败 事件 
	 * @author 破晓
	 * 
	 */	
	public class NetFaultEvent extends Event
	{
		
		public static const FAULT:String = "fault";
		
		private	var _fault:Fault;
		
		private var _data:Object;
		
		private var _session:Session;
		
		/**
		 * 构造函数 
		 * @param data
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function NetFaultEvent(data:*, sessionInfo:Session=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_data = data;
			_session = sessionInfo;
			_session.endTime = getTimer();
			
			var message:String;
			if(data is DataVo)
			{
				message = data.errorMessage;
				_fault = new Fault("-2012", "服务器内部异常", message);
			}
			else if(data is IOErrorEvent)
			{
				message = data.toString();
				_fault = new Fault("-2011", "IO异常", message);
			}
			else if(data is SecurityErrorEvent)
			{
				message = data.toString();
				_fault = new Fault("-2010", "安全性异常", message);
			}
			else
			{
				message = data + "";
				_fault = new Fault("-2013", "未知错误", message)
			}
			
			super(FAULT, bubbles, cancelable);
		}
		
		
		
		public function get session():Session
		{
			return _session;
		}
		
		override public function clone():Event
		{
			var e:NetFaultEvent = new NetFaultEvent(_data);
			e._session = _session;
			
			return e;
		}
		
		public function get fault():Fault
		{
			return _fault;
		}
		
	}
}



class Fault
{
	private var _code:String;
	private var _title:String;
	private var _message:String;
	
	public function Fault(code:String, title:String, msg:String)
	{
		_code = code;
		_title = title;
		_message = msg;
	}
	
	public function get message():String
	{
		return _message;
	}
	
	public function set message(value:String):void
	{
		_message = value;
	}
	
	public function get title():String
	{
		return _title;
	}
	
	public function get code():String
	{
		return _code;
	}
	
	public function toString():String
	{
		return "Error:" + _code + "; " + _title +  "; " + _message;
	}
}