package com.airmyth.net.as3network.model
{
  import com.airmyth.net.as3network.net.IInvoker;
  import com.airmyth.net.as3network.net.http.ASCallDotNet;
  import com.airmyth.net.as3network.net.http.ASCallJava;
  import com.airmyth.net.as3network.net.http.ASCallPHP;
  
  import flash.utils.Dictionary;
  import flash.utils.getDefinitionByName;
  import flash.utils.getQualifiedClassName;

  public class Server
  {
    /** 服务器标记*/  
    public var id:String;
    /** 服务器地址*/
    public var url:String;
    /** 服务器类型*/
    public var type:String;
    /** 服务器协议*/
    public var protocol:String;
    /** IInvoker实例列表 */
    private var services:Dictionary = new Dictionary();
    
    public function getInvoker(serviceName:String):IInvoker
    {
      var _invoker:IInvoker = services[serviceName];
      if(_invoker) return _invoker;
      
      if(protocol == ProtocolAndServer.P_HTTP)
      {
        switch(type)
        {
          case ProtocolAndServer.S_JAVA: _invoker = new ASCallJava(this, serviceName);break;
          case ProtocolAndServer.S_DOT_NET: _invoker = new ASCallDotNet(this, serviceName);break;
          case ProtocolAndServer.S_PHP: _invoker = new ASCallPHP(this, serviceName);break;
        }
      }
      
      services[serviceName] = _invoker;
      return _invoker;
    }
    
    /** 所有未能实现IModelBasic的数据模型 */
    private var regularModels:Dictionary = new Dictionary();
    
    /** 数据对象映射表*/
    public var models:Dictionary = new Dictionary();
    public var serverModelList:Dictionary = new Dictionary();
    
    public function registerModelClass(model:Class, serverModel:String, regular:Boolean):void
    {
      if(model && serverModel != null && serverModel != "")
      {
        models[model] = serverModel;
        serverModelList[serverModel] = model;
      }
      
      if(!regular)
        regularModels[serverModel] = model;
    }
    
    public function getModel(serverModel:String):Class
    {
      var cla:Class = serverModelList[serverModel];
      if(!cla)
        cla = getDefinitionByName(serverModel) as Class;
      return cla;
    }
    
    public function getServerModel(model:Class):String
    {
      if(models.hasOwnProperty(model))
        return models[model];
      var cn:String = getQualifiedClassName(model);
      return cn;
    }
    
    public function getServerModelByData(model:*):String
    {
      var cn:String = getQualifiedClassName(model);
      var cls:Class =  getDefinitionByName(cn) as Class;
      return models[cls] || cn.replace("::", ".");
    }
    
    public function removeModel(model:Class):void
    {
      if(models.hasOwnProperty(model))
        delete models[model];
      for(var sm:String in serverModelList)
      {
        if(serverModelList[sm] == model)
        {
          delete serverModelList[sm];
          break;
        }
      }
    }
    
    /**
     * 校验数据是否为数据模型
     * @param m
     * @return 
     * 
     */    
    public function checkRegularModels(m:Object):Boolean
    {
      for each(var cls:Class in regularModels)
      {
        if(m is cls)
          return true;
      }
      return false;
    }
  }
}