package com.airmyth.net.as3network.model
{
  import com.airmyth.net.as3network.net.http.AbstractChannel;
  import com.airmyth.net.as3network.net.http.AbstractInvoker;
  import com.airmyth.net.as3network.net.http.Method;
  
  import flash.utils.ByteArray;
  import flash.utils.getTimer;

  public class Session
  {
    public var data:DataVo = new DataVo();
    public var url:String;
    
    public var invoker:AbstractInvoker;
	/** 方法 */
    public var method:Method;
    public var resultHandler:Function;
    public var faultHandler:Function;
	
	public var paramTypes:Array;
    
	/** 开始精确时间 */
	public var startDate:Date;
	/** 开始时间 */
	public var startTime:int;
	/** 结束时间 */
	public var endTime:int;
    
    private var _resultData:ByteArray;
    
    
	/**
	 * 通信耗时 
	 * @return 
	 * 
	 */	
	public function get consumingTime():int
	{
		return endTime - startTime;
	}
	
	private var _status:String = "init";
	
	public function get canRun():Boolean
	{
		return _status == "init";
	}
	
	
	private var _channel:AbstractChannel;
	
	/**
	 * 开始 
	 * 
	 */    
	public function start(channel:AbstractChannel):void
	{
		startDate = new Date();
		startTime = getTimer();
		_status = "start";
		_channel = channel;
	}
	
	/**
	 * 正常结束
	 * 
	 */    
	public function stop():void
	{
		_status = "stop";
		_channel = null;
	}
	
	/**
	 * 中止 
	 * 
	 */    
	public function skip():void
	{
		_status = "skip";
		if(_channel)
		{
			_channel.close();
			_channel = null;
		}
	}
	
    /**
     * 请求数据 
     * @return 
     * 
     */    
    public function get resultData():ByteArray
    {
      _resultData ||= invoker.getRequestData(this);
      return _resultData;
    }

//    public function getResultData():ByteArray
//    {
//      return invoker.getRequestData(data);
//    }
  }
}