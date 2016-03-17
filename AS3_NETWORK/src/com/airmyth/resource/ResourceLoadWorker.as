package com.airmyth.resource
{
  import flash.display.Loader;
  import flash.events.Event;
  import flash.events.HTTPStatusEvent;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.URLRequest;
  import flash.net.URLStream;
  import flash.system.LoaderContext;
  import flash.utils.ByteArray;
  import flash.utils.getTimer;

  public class ResourceLoadWorker
  {
    private var _resource:Resource;
    
    private var _resLoaderManager:ResourceManager;
    
    /**
     * 显示对象下载器 
     */		
    private var _loader:Loader = null;
    
    /**
     * 显示对象下载器 
     */		
    private var _streamLoader:URLStream = null;
    
    /**
     * 下载过程中的计时器 
     */		
    private var _tempTime :int = 0;
    /**上个时段加载的字节数*/
    private var _tempSourceSize :Number = 0;
    
    private var _isLoading:Boolean;
    
    public function ResourceLoadWorker(resLoaderManager:ResourceManager)
    {
      _resLoaderManager = resLoaderManager;
      _tempTime = getTimer();
    }
    /**
     * 下载资源 
     * @param a_url
     * @return 
     * 
     */		
    public function load(res:Resource):void
    {
      _resource = res;
      reLoad();
    }
    
    public function reLoad():void
    {
      _isLoading = true;
      if(_resource.isStreamSource())
        loadStreamSource();
      else
        loadSource();
    }
    
    private function loadStreamSource():void
    {
      _streamLoader = new URLStream();
      _streamLoader.addEventListener(Event.COMPLETE,onLoadCompleteHandler);
      _streamLoader.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorHanander);
      _streamLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onIOErrorHanander);
      _streamLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
      _streamLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
      
      var request:URLRequest = new URLRequest(_resource.url + "?v=" + _resource.version);
      _streamLoader.load(request);
    }
    
    private function loadSource():void
    {
      _loader = new Loader();
      _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadCompleteHandler);
      _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOErrorHanander);
      _loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onIOErrorHanander);
      _loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
      _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
      
      var request:URLRequest = new URLRequest(_resource.url + "?v=" + _resource.version);
      _loader.load(request , new LoaderContext(true));
      trace("load url worker start " + _resource.url);
    }
    
    /**
     * 停止正在的下载 
     * 
     */		
    public function Stop():void
    {
      if(_loader)
      {
        _loader.unload();
        _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadCompleteHandler);
        _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHanander);
        _loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onIOErrorHanander);
        _loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,onHttpStatus);
        _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        _loader = null;
      }
      
      if(_streamLoader)
      {
        _streamLoader.close();
        _streamLoader.removeEventListener(Event.COMPLETE,onLoadCompleteHandler);
        _streamLoader.removeEventListener(IOErrorEvent.IO_ERROR,onIOErrorHanander);
        _streamLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onIOErrorHanander);
        _streamLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
        _streamLoader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
        _streamLoader = null;
      }
      _isLoading = false;
    }
    /**
     * 是否正在下载 
     * @return 
     * 
     */		
    public function isLoading():Boolean
    {
      return _isLoading;
    }
    
    private function onHttpStatus(a_event:Event):void
    {
      //trace("onHttpStatus " + a_event.toString() + " url:" + _url);
    }
    
    private function onProgress(a_event:ProgressEvent):void
    {
      if(getTimer() - _tempTime < 200) return;
      var time :int = getTimer() - _tempTime;
      var speed :Number = (a_event.bytesLoaded - _tempSourceSize) / time;
      if(a_event.bytesLoaded < _tempSourceSize)
      {
        speed = a_event.bytesLoaded / time;
      }
      _tempTime = getTimer();
      _tempSourceSize = a_event.bytesLoaded;
      var loader:Loader = _loader;
      if(a_event.bytesTotal != 0)
        _resLoaderManager.OnLoadProgress(_resource , a_event.bytesTotal, a_event.bytesLoaded, speed);
      else
        _resLoaderManager.OnLoadProgress(_resource , 0, 0, 0);
    }
    /**
     * 下载成功 
     * @param a_event
     * 
     */	
    private function onLoadCompleteHandler(a_event:Event):void
    {
      //			_tempSourceSize += loaderInfo.bytesTotal;
      var resData:Object = a_event.target;
      if(a_event.target is URLStream)
      {
        var bytes:ByteArray = new ByteArray();
        var stream:URLStream = URLStream(a_event.target);
        stream.readBytes(bytes, 0, stream.bytesAvailable);
        bytes.position = 0;
        resData = bytes;
      }
      _resLoaderManager.OnLoadURLSucceed(_resource, resData);
      Stop();
    }
    /**
     * 下载失败 
     * @param a_event
     * 
     */		
    private function onIOErrorHanander(a_event:Event):void
    {
      Stop();
      _resLoaderManager.OnLoadURLFailed(_resource, this);
    }
  }
}