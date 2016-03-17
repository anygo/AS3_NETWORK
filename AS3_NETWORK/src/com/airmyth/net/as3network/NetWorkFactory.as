package com.airmyth.net.as3network
{
  import com.airmyth.net.as3network.model.Server;
  import com.airmyth.net.as3network.model.Session;
  import com.airmyth.net.as3network.net.IInvoker;
  import com.airmyth.net.as3network.net.http.Method;
  import com.airmyth.net.as3network.util.IParamEncrypt;
  import com.airmyth.net.as3network.util.IParamResolve;
  import com.airmyth.resource.IResouceLoadListener;
  import com.airmyth.resource.Resource;
  import com.airmyth.resource.ResourceManager;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.utils.Dictionary;
  import flash.utils.getDefinitionByName;
  
  [Event(name="complete", type="flash.events.Event")]
  
  /**
   * 后台访问工厂 
   * @author sdhd
   * 
   */  
  public class NetWorkFactory extends EventDispatcher implements IResouceLoadListener
  {
    public static var default_url:String = "assets/configs/serverConfig.xml";
    
    private var serverList:Dictionary = new Dictionary();
    private var defaultServer:Server;
    
    private var callList:Dictionary = new Dictionary();
    
    private static var _instances:Dictionary = new Dictionary();
    
    private var isLoaded:Boolean;
    
    public function NetWorkFactory(config_URL:String=null)
    {
      super();
      configUrl = config_URL || default_url;
    }
    
	public function get configXML():XML
	{
		return _configXML;
	}

    /**
     * 获取实例 
     * @param config_URL
     * @return 
     * 
     */    
    public static function getInstance(config_URL:String=null):NetWorkFactory
    {
      config_URL ||= default_url;
      var factory:NetWorkFactory = _instances[config_URL];
      if(!factory)
      {
        factory = new NetWorkFactory(config_URL);
        _instances[config_URL] = factory;
      }
      
      return factory;
    }
    
    /**
     * 服务器配置文件路径 
     * @param value
     * 
     */    
    public function set configUrl(value:String):void
    {
      ResourceManager.getInstance().loadText(value, "serverConfig", this);
    }
    
    /**
     * 获取服务 
     * @param serviceName
     * @param server
     * @return 
     * 
     */    
    public function getService(serviceName:String, server:String=null):IInvoker
    {
      var s:Server = defaultServer;
      if(server)
        s = serverList[server];
      if(s)
        return s.getInvoker(serviceName);
      
      return null;
    }
    
    /**
     * 获取服务器实例 
     * @param sid
     * @return 
     * 
     */    
    public function getServer(sid:String = null):Server
    {
      if(sid)
        return serverList[sid];
      else
        return defaultServer;
    }
    
    /**
     * 获取服务方法 
     * @param serviceName
     * @param methodName
     * @param server
     * @return 
     * 
     */    
    public function getMethod(serviceName:String, methodName:String, server:String=null):Method
    {
      var invoker:IInvoker = getService(serviceName, server);
      if(!invoker)
        return null;
      
      return invoker.getMethod(methodName);
    }
    
    /**
     * 调用服务方法 
     * @param serviceName
     * @param methodName
     * @param param
     * @param result
     * @param fault
     * @param outerResolve
     * @param server
     * @return 
     * 
     */    
    public function send(serviceName:String, methodName:String, param:Array=null, result:Function=null, fault:Function=null, outerResolve:IParamResolve=null, server:String=null):Session
    {
      var invoker:IInvoker = getService(serviceName, server);
      if(!invoker)
        return null;
      
      invoker.outerResolve = outerResolve || _outerResolve;
      invoker.outerEncrypt = _outerEncrypt;
      return invoker.send(methodName, param, result, fault);
    }
    
    private var _outerResolve:IParamResolve = null;
    
    /**
     *  
     * @param value
     * @return 
     * 
     */    
    public function setOuterResolve(value:IParamResolve):NetWorkFactory
    {
      _outerResolve = value;
      
      return this;
    }
    
    private var _outerEncrypt:IParamEncrypt = null;
    
    /**
     * 外部加密解密接口 
     * @param value
     * @return 
     * 
     */    
    public function setOuterEncrypt(value:IParamEncrypt):NetWorkFactory
    {
      _outerEncrypt = value;
      
      return this;
    }
    
	private var _configXML:XML;
	
    public function onResourceLoaded(resource:Resource):void
    {
		_configXML = new XML(resource.getTextData());
      
      var server:Server;
      var cls:Class;
      for each(var item:XML in _configXML.servers.server)
      {
		  if(serverList[item.@id.toString()])
        		server = serverList[server.id];
		  else
			  server =  new Server();
        server.id = item.@id;
        server.url = item.@url;
        server.type = item.@type;
        server.protocol = item.@protocol;
        
        
        
        for each(var m:XML in item.model.item)
        {
          cls =  getDefinitionByName(m.@clientClass.toString()) as Class;
          server.registerModelClass(cls, m.@serverClass.toString(), m.@regular.toString() != "false");
        }
        
        serverList[server.id] = server;
      }
      
      defaultServer = serverList[_configXML.servers.@defaultServer.toString()];
      
      isLoaded = true;
      dispatchEvent(new Event(Event.COMPLETE));
    }
    
    public function get complete():Boolean
    {
      return isLoaded;
    }
    
    public function set isCache(value:Boolean):void
    {
    }
    
    public function get isCache():Boolean
    {
      return false;
    }
    
    public function onLoadProgress(resource:Resource, bytesTotal:Number, bytesLoaded:Number, speed:Number):void
    {
    }
    
    public function onResourceLoadFailed(resource:Resource):void
    {
      throw new Error("配置文件加载失败");
    }
  }
}