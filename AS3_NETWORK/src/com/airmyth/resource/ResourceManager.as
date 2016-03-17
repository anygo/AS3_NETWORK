package com.airmyth.resource
{
  import flash.display.BitmapData;
  import flash.display.MovieClip;
  import flash.utils.Dictionary;
  
  public class ResourceManager
  {
    /** 加载器最大数量*/
    public const MAX_RESOURCE_LOAD_WORKER:int = 3;
    
    /**
     * 资源管理器容器 
     */		
    private static var _resLoaderMgrs:Dictionary = new Dictionary();
    /**
     * 资源缓存容器 
     */		
    private var _allResourceCache:Dictionary = new Dictionary();
    
    /**
     * 下载器池
     */		
    private var _loadWorkers:Array = [];
    /**
     * 下载请求队列 
     */		
    private var _loadRequest:Array = [];
    
    private var resourceParentList:Dictionary = new Dictionary();
    
    public function ResourceManager()
    {
      // 初始化下载器池			
      for(var i:int = 0; i < MAX_RESOURCE_LOAD_WORKER; i++)
      {
        _loadWorkers.push(new ResourceLoadWorker(this));
      }
    }
    
    /**
     * 加载文本资源 
     * @param a_url 资源地址
     * @param a_name 资源名字，用于回调函数中
     * @param a_listener 资源加载侦听者
     * @param isCache 是否缓存资源
     * @param charSet 字符集
     * 
     */    
    public function loadText(a_url:String, a_name:String, a_listener:IResouceLoadListener, isCache:Object=null, charSet:String="UTF-8"):void
    {
      loadResource(Resource.RESOURCE_TYPE_TEXT, a_url, a_name, null, a_listener, "0.0.0", isCache, null, charSet);
    }
    
    /**
     *  加载资源
     * @param a_type 资源类型
     * @param a_url 资源地址
     * @param a_name 资源名字，用于回调函数中
     * @param childKey  子资源名字，SWF资源中的导出对象
     * @param a_listener 资源加载侦听者
     * @param isCache 是否缓存资源
     * @param charSet 字符集
     * 
     */    
    public function loadResource(a_type:int, a_url:String, a_name:String, childKey:String, a_listener:IResouceLoadListener, version:String="0.0.0", isCache:Object=null, parentIsCache:Object=null, charSet:String="UTF-8"):void
    {
      var resource:Resource;
      var key:String = getResourceKey(a_url, childKey);
      if(_allResourceCache.hasOwnProperty(key))
      {
        resource = _allResourceCache[key];
        if(resource.version != version)
        {
          resource = null;
        }
      }
      if(resource)
      {
        // 存在资源
        if(a_listener)
        {
          if(resource.isLoaded())
          {
            resource.name = a_name;
            // 存在资源且已加载过，直接回调
            a_listener.onResourceLoaded(resource);
          }
          else
          {
            // 存在资源但未加载，加入侦听列表中
            resource.addListener(a_listener);
            addResourceRequest(resource);
          }
        }
      }
      else
      {
        // 资源不存在, 创建资源
        resource = new Resource(a_type, a_url, a_name , childKey, charSet);
        resource.version = version;
        if(a_listener)
          resource.addListener(a_listener);
        if((isCache == null && a_listener && a_listener.isCache) || isCache == true)
          _allResourceCache[key] = resource;
        // 加入资源加载请求队列
        addResourceRequest(resource);
      }
      // 处理资源加载请求
      processResourceRequest(parentIsCache);
    }
    
    /**
     * 处理资源加载请求 
     * 
     */		
    private function processResourceRequest(parentIsCache:Object=null):void
    {
      var resource:Resource = getResourceRequest();
      if(resource && !resource.isLoaded())
      {
        if(resource.type == Resource.RESOURCE_TYPE_BITMAP)
        {
          processBmpLoad(resource, parentIsCache);
        }
        else if(resource.type == Resource.RESOURCE_TYPE_MOVIECLIP)
        {
          processMCLoad(resource, parentIsCache);
        }
        else
        {
          if(!LoadResourceURL(resource))
            addResourceRequest(resource);
        }
      }
    }
    
    /**
     * 处理Bmp加载请求 
     * @param a_res
     * @param a_key
     * 
     */		
    private function processBmpLoad(a_res:Resource, parentIsCache:Object=null):void
    {
      if(a_res.childKey == null)
      {
        // 不是子资源，下载图片文件
        if(!LoadResourceURL(a_res))
          addResourceRequest(a_res);
      }
      else
      {
        // 是子资源，从父资源中获得
        var parentKey:String = getResourceKey(a_res.url, null);
        var parentResource:Resource = findCacheResourceByKey(parentKey);
        if(parentResource)
        {
          var bitmap:BitmapData = parentResource.getSubResAsBitmap(a_res.childKey);
          if(bitmap)
          {
            // 加载完成
            a_res.setBitmapData(bitmap, parentResource);
          }
          else
          {
            if(!parentResource.isLoadFailed())
            {
              // 加入父资源响应列表
              addResourceParentList(parentKey, a_res);
            }
          }
        }
        else
        {
          // 加载父资源
          loadResource(Resource.RESOURCE_TYPE_SWF, a_res.url, null, null, null, a_res.version, parentIsCache);
          // 加入父资源响应列表
          addResourceParentList(parentKey, a_res);
        }
      }
    }
    
    /**
     * 处理MovieClip加载请求 
     * @param a_res
     * @param a_key
     * 
     */		
    private function processMCLoad(a_res:Resource, parentIsCache:Object=null):void
    {
      var parentKey:String = getResourceKey(a_res.url, null);
      var parentResource:Resource = findCacheResourceByKey(parentKey);
      if(parentResource)
      {
        var movieClip:MovieClip = parentResource.getSubResAsMovieClip(a_res.childKey);
        if(movieClip)
        {
          // 加载完成
          a_res.SetMovieClipData(movieClip, parentResource);
        }
        else
        {
          if(!parentResource.isLoadFailed())
          {
            // 加入父资源响应列表
            addResourceParentList(parentKey, a_res);
          }
        }
      }
      else
      {
        // 加载父资源
        loadResource(Resource.RESOURCE_TYPE_SWF, a_res.url, null, null, null, a_res.version, parentIsCache);
        
        // 加入父资源响应列表
        addResourceParentList(parentKey, a_res);
      }
    }
    
    /**
     * 开始资源加载 
     * @param a_url
     * @param a_key
     * @return 
     * 
     */		
    private function LoadResourceURL(resource:Resource):Boolean
    {
      for(var i:int = 0; i < MAX_RESOURCE_LOAD_WORKER; i++)
      {
        if(!_loadWorkers[i].isLoading())
        {
          _loadWorkers[i].load(resource);
          return true;
        }
      }
      return false;
    }
    
    private function addResourceParentList(parentKey:String, res:Resource):void
    {
      if(resourceParentList[parentKey] == null)
        resourceParentList[parentKey] = [];
      resourceParentList[parentKey].push(res);
    }
    
    /**
     * 增加资源加载请求 
     * @param a_key
     * 
     */		
    private function addResourceRequest(res:Resource):void
    {
      _loadRequest.push(res);
    }
    /**
     * 获得一个资源加载请求 
     * @return 
     * 
     */		
    private function getResourceRequest():Resource
    {
      return _loadRequest.shift();
    }
    /**
     * 是否有资源加载请求 
     * @return 
     * 
     */		
    private function hasResourceRequest():Boolean
    {
      return _loadRequest.length > 0;
    }
    
    /**
     * 查找资源 
     * @param a_key
     * @return 
     * 
     */		
    private function findCacheResourceByKey(a_key:String):Resource
    {
      if(_allResourceCache.hasOwnProperty(a_key))
        return _allResourceCache[ a_key ];
      return null;
    }
    
    /**
     * 添加资源缓存 
     * @param a_url
     * @param childKey
     * @param res
     * 
     */    
    public function addResourceCache(a_url:String, childKey:String, res:Resource):void
    {
      var key:String = getResourceKey(a_url, childKey);
      _allResourceCache[key] = res;
    }
    
    /**
     * 删除资源缓存 
     * @param a_url
     * @param childKey
     * 
     */    
    public function removeResourceCache(a_url:String, childKey:String):void
    {
      var key:String = getResourceKey(a_url, childKey);
      if(_allResourceCache.hasOwnProperty(key))
        delete _allResourceCache[key];
    }
    
    /**
     * 根据URL和子资源名字获得资源 
     * @param a_url
     * @param a_subRes
     * @return 
     * 
     */		
    private function getChildResByChildKey(a_url:String, childKey:String):Resource
    {
      var key:String = getResourceKey(a_url, childKey);
      if(_allResourceCache.hasOwnProperty(key))
        return _allResourceCache[ key ];
      return null;
    }
    
    /**
     * 资源加载进度更新 
     * @param a_key
     * @param a_percent
     * 
     */		
    internal function OnLoadProgress(res:Resource, bytesTotal:Number, bytesLoaded:Number, speed:Number):void
    {
      if(res)
        res.SetLoadProgress(bytesTotal, bytesLoaded, speed);
    }
    /**
     * 资源加载成功 
     * @param a_key
     * @param a_loadInfo
     * 
     */		
    internal function OnLoadURLSucceed(res:Resource, a_loadInfo:Object):void
    {
      if(res)
      {
        res.SetLoadSucceed(a_loadInfo);
        var key:String = getResourceKey(res.url, null);
        var childrenRes:Array = resourceParentList[key];
        for each(var item:Resource in childrenRes)
        {
          item.setDataByType(res.getChildDataByType(item.childKey, item.type));
          item.SetLoadSucceed(null);
        }
        delete resourceParentList[key];
      }
      // 处理资源加载请求
      processResourceRequest();
    }
    
    /**
     * 资源加载失败 
     * @param a_key
     * 
     */		
    internal function OnLoadURLFailed(res:Resource, work:ResourceLoadWorker):void
    {
      if(res)
      {
        if(res.canLoadRetry()){
          res.SetLoadFailed();
          addResourceRequest(res);  //work.reLoad();
        }
        else
          res.CallListenerLoadFailed();
      }
      // 处理资源加载请求
      processResourceRequest();
    }

    /**
     * 获得资源key 
     * @param a_url
     * @param a_subRes
     * @return 
     * 
     */		
    private function getResourceKey(a_url:String, childKey:String):String
    {
      if(childKey)
        return a_url + "@" + childKey;
      return a_url;
    }
    
    /**
     * 清除所有资源及正在下载的资源 
     * 
     */		
    public function clear():void
    {
      for(var i:int = 0; i < MAX_RESOURCE_LOAD_WORKER; i++)
      {
        if(_loadWorkers[i].isLoading())
        {
          _loadWorkers[i].Stop();
        }
      }
      
      _loadRequest.splice(0);
      
      for(var key:Object in _allResourceCache)
      {
        var res:Resource = _allResourceCache[key];
        res.clear();
        delete _allResourceCache[key];
      }
    }
    /**
     * 获得资源管理器 
     * @param a_resMgrName
     * @return 
     * 
     */		
    public static function getInstance(a_resMgrName:String = "default"):ResourceManager
    {
      if(!_resLoaderMgrs.hasOwnProperty(a_resMgrName))
        _resLoaderMgrs[ a_resMgrName ] = new ResourceManager;
      return _resLoaderMgrs[ a_resMgrName ];
    }
  }
}