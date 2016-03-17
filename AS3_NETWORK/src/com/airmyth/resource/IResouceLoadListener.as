package com.airmyth.resource
{
  public interface IResouceLoadListener
  {
    function onResourceLoaded(resource:Resource):void;
    /**
     * 派发进度 
     * @param resource 资源
     * @param bytesTotal 总字节数
     * @param bytesLoaded 下载的字节数
     * @param speed 下载速度（字节/毫秒）
     * 
     */    
    function onLoadProgress(resource:Resource, bytesTotal:Number, bytesLoaded:Number, speed:Number):void;
    function onResourceLoadFailed(resource:Resource):void;
    
    /**
     * 资源是否缓存 
     * @param value
     * 
     */    
    function set isCache(value:Boolean):void;
    function get isCache():Boolean;
  }
}