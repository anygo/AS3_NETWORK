package com.airmyth.net.as3network.net.http
{
  import com.airmyth.net.as3network.model.Session;
  
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLStream;
  import flash.utils.ByteArray;
  import flash.net.URLRequestHeader;
  
  /**
   * 通信通道 
   * @author airmyth
   * 
   */  
  public class AbstractChannel
  {
    private var loader:URLStream = new URLStream();
    private var request:URLRequest = new URLRequest();
    
    private var _isLoading:Boolean;
    
    private var _task:Session;
    
    private var requestDatas:Array = [];
    
    public function send(task:Session):void
    {
		task.start(this);
      _isLoading = true;
      _task = task;
      
      loader.addEventListener(Event.COMPLETE, onCompleteHandler);
      loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
      
      request.method = URLRequestMethod.POST;
      request.contentType = "application/octet-stream";
      request.url = _task.url;
	  
	  request.requestHeaders.length = 0;
	  var heads:Object = task.data.requestHeads;
	  if(heads)
	  {
		  for(var key:String in heads)
			  request.requestHeaders.push(new URLRequestHeader(key, heads[key]));
	  }
      
      request.data = _task.resultData;
      
      loader.load(request);
    }
    
    private function onCompleteHandler(event:Event):void
    {
		var stream :URLStream = event.currentTarget as URLStream;
		if(stream.bytesAvailable == 0)
		{
			if(requestDatas.length == 0)
			{
				_task.invoker.fail(event, _task);
				close();
			}
			else
			{
				request.data = requestDatas.shift();
				loader.load(request);
			}
			
			return;
		}
		
		var resultStream:ByteArray = new ByteArray();
		stream.readBytes(resultStream, 0, stream.bytesAvailable);
		
		_task.invoker.success(resultStream, _task);
		
		close();
    }
    
    private function httpStatusHandler(event:HTTPStatusEvent):void
    {
      _task.data.httpStatus = event;
    }
    
    private function securityErrorHandler(event:SecurityErrorEvent):void
    {
      _task.invoker.fail(event, _task);
      close();
    }
    private function ioErrorHandler(event:IOErrorEvent):void
    {
      _task.invoker.fail(event, _task);
      
      close();
    }
    
    /**
     * 关闭连接，等待垃圾回收 
     * 
     */		
    public function close():void
    {
      loader.close();
      loader.removeEventListener(Event.COMPLETE, onCompleteHandler);
      loader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
      loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
      
	  _task.stop();
	  _task = null;
      
      _isLoading = false;
      
      AbstractChannelManager.getInstance().pushChannel(this);
      AbstractChannelManager.getInstance().doNextTask();
    }
    
    public function get isLoading():Boolean
    {
      return _isLoading;
    }
  }
}