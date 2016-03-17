package com.airmyth.net.as3network.net
{
  import com.airmyth.IDestroy;
  import com.airmyth.net.as3network.model.Server;
  import com.airmyth.net.as3network.model.Session;
  import com.airmyth.net.as3network.net.http.Method;
  import com.airmyth.net.as3network.util.IParamEncrypt;
  import com.airmyth.net.as3network.util.IParamResolve;
  
  public interface IInvoker extends IDestroy
  {
    function send(methodName:String, params:Array=null, resultHandler:Function=null, faultHandler:Function=null, paramTypes:Array=null, requestHeads:Object=null):Session;
    function close():void;
    
    function getMethod(name:String):Method;
    
    function get server():Server;
    function set server(value:Server):void;
    
    function set outerResolve(value:IParamResolve):void;
    function set outerEncrypt(value:IParamEncrypt):void;
    
    function get isClose():Boolean;
  }
}