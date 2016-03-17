package com.airmyth.resource
{
  import com.airmyth.util.CloneUtil;
  
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.DisplayObject;
  import flash.display.LoaderInfo;
  import flash.display.MovieClip;
  import flash.display.SimpleButton;
  import flash.errors.IllegalOperationError;
  import flash.system.ApplicationDomain;
  import flash.utils.ByteArray;

  public class Resource
  {
    /**
     * 资源类型 
     */	
    public static const RESOURCE_TYPE_UNKNOW:int = 0;
    public static const RESOURCE_TYPE_SWF:int = 1;
    public static const RESOURCE_TYPE_BITMAP:int = 2;
    public static const RESOURCE_TYPE_MOVIECLIP:int = 3;
    public static const RESOURCE_TYPE_TEXT:int = 4;
    public static const RESOURCE_TYPE_BYTEARRAY:int = 5;
    
    /**
     * 资源状态 
     */		
    public static const RESOURCE_STATE_INIT:int = 0;
    public static const RESOURCE_STATE_LOAD_SUCCEED:int = 1;
    public static const RESOURCE_STATE_LOAD_FAILED:int = 2;
    
    /**
     *		版本号 
     */		
    public var version:String= "0.0.0";
    private var _type:int = 0;
    private var _state:int = RESOURCE_STATE_INIT;
    private var _url:String;
    private var _childKey:String;
    private var _name:String;
    
    private var _charset:String;
    
    /**
     * 资源加载完成回调 
     */		
    private var _listeners:Array = [];
    
    /**
     * SWF数据 
     */		
    private var _appDomain:ApplicationDomain = null;
    
    private var _loaderInfo:LoaderInfo;
    /**
     * 位图数据 
     */		
    private var _bitmapData:BitmapData = null;
    /**
     * MC数据 
     */		
    private var _movieClip:MovieClip = null;
    /**
     * 文本数据 
     */		
    private var _txtSource:ByteArray = null;
    /**
     * 二进制数据 
     */		
    private var _byteArray:ByteArray = null;
    
    /**
     * ResourcePack 资源包数据对象
     */		
    private var _packObject:Object = null;
    /**
     * 下载失败重试次数 
     */		
    private var _loadRetryTimes:int = 5;
    
    public function Resource(type:int, url:String, name:String, childKey:String, charset:String="UTF-8")
    {
      _type = type;
      _url = url;
      _name = name;
      _childKey = childKey;
      _charset = charset;
    }

    /////////////////////////////////////////////////////////////////////
    ////
    ////                               Getter and Setter
    ////
    /////////////////////////////////////////////////////////////////////

    /**
     * 类型 
     */
    public function get type():int
    {
      return _type;
    }

    /**
     * 加载状态 
     */
    public function get state():int
    {
      return _state;
    }

    /**
     * 资源地址 
     */
    public function get url():String
    {
      return _url;
    }

    /**
     * 子资源名字 
     */
    public function get childKey():String
    {
      return _childKey;
    }


    /**
     * 资源名字 
     */
    public function get name():String
    {
      return _name;
    }
    
    /**
     * 资源名字 
     */
    public function set name(value:String):void
    {
      _name = value;
    }
    
    /**
     * 父资源 
     */		
    private var _parent:Resource = null;

    public function get charset():String
    {
      return _charset;
    }

    public function set charset(value:String):void
    {
      _charset = value;
    }
    
    public function isStreamSource():Boolean
    {
      return checkSourceIsStream(_type);
    }
    
    public static function checkSourceIsStream(resType:int):Boolean
    {
      return (resType == RESOURCE_TYPE_TEXT || resType == RESOURCE_TYPE_BYTEARRAY);
    }

    /**
     * 是否加载成功 
     * @return 
     * 
     */		
    public function isLoaded():Boolean
    {
      return _state == RESOURCE_STATE_LOAD_SUCCEED;
    }
    /**
     * 是否加载失败 
     * @return 
     * 
     */		
    public function isLoadFailed():Boolean
    {
      return _state == RESOURCE_STATE_LOAD_FAILED;
    }
    
    /**
     * 增加侦听对象 
     * @param a_listener
     * 
     */		
    public function addListener(a_listener:Object):void
    {
		  if(a_listener)
        _listeners.push(a_listener);
    }
    
    /**
     * 设置下载进度 
     * @param a_percent
     * 
     */		
    public function SetLoadProgress(bytesTotal:Number, bytesLoaded:Number, speed:Number):void
    {
      for each(var item:IResouceLoadListener in _listeners)
      {
          item.onLoadProgress(this, bytesTotal, bytesLoaded, speed);
      }
    }
    
    /**
     * 加载成功 
     * 
     */		
    public function SetLoadSucceed(data:Object):void
    {
      _state = RESOURCE_STATE_LOAD_SUCCEED;
      if(_type == RESOURCE_TYPE_SWF )
        setSwfData(data as LoaderInfo);
      else if(_type == RESOURCE_TYPE_BITMAP )
      {
        if(_childKey == null)
          setBitmapData(Bitmap(data.content).bitmapData, null );
      }
      else if(_type == RESOURCE_TYPE_MOVIECLIP )
      {
        trace( "resource type error: movieclip must in swf resource! " + _url + ":" + _childKey);
      }
      else if(isStreamSource())
      {
        if(_type == RESOURCE_TYPE_TEXT)
          _txtSource = data as ByteArray;
        else
          _byteArray = data as ByteArray;
      }
      
      callLoadSuccessListener();
    }
    
    private function callLoadSuccessListener():void
    {
      for each(var item:IResouceLoadListener in _listeners)
      {
        item.onResourceLoaded(this);
      }
      _listeners = [];
    }
    
    /**
     * 加载失败 
     * 
     */		
    public function SetLoadFailed():void
    {
      if(_loadRetryTimes > 0)
        _loadRetryTimes--;
      else
        _state = RESOURCE_STATE_LOAD_FAILED;
    }
    
    /**
     *		调用侦听对象,下载失败 
     * 
     */		
    public function CallListenerLoadFailed():void
    {
      for each(var item:IResouceLoadListener in _listeners)
      {
        item.onResourceLoadFailed(this);
      }
      _listeners = [];
    }
    
    /**
     * 下载失败后是否还可以重试 
     * @return 
     * 
     */    
    public function canLoadRetry():Boolean
    {
      return _loadRetryTimes > 0;
    }
    /**
     * 清除资源 
     * 
     */		
    public function clear():void
    {
      if(_bitmapData)
        _bitmapData.dispose();
      _bitmapData = null;
      _appDomain = null;
      _movieClip = null;
      _parent = null;
      _byteArray = null;
      _txtSource = null;
      // Clear Listeners
      for(var key:Object in _listeners)
      {
        delete _listeners[key];
      }
      _state = RESOURCE_STATE_INIT;
    }
    /**
     * 设置SWF数据 
     * @param a_appDomain
     * 
     */		
    private function setSwfData(a_loaderInfo:LoaderInfo):void
    {
      _loaderInfo = a_loaderInfo
      _appDomain = a_loaderInfo.applicationDomain;
    }
    
    public function setDataByType(data:*, a_parent:Resource = null):void
    {
      if(data is BitmapData)
        setBitmapData(BitmapData(data), a_parent);
      else if(data is MovieClip)  
        SetMovieClipData(MovieClip(data), a_parent);
    }
    
    
    /**
     * 设置Bitmap数据 
     * @param a_bitmap
     * @param a_parent
     * 
     */		
    public function setBitmapData(a_bitmap:BitmapData, a_parent:Resource = null):void
    {
      _bitmapData = a_bitmap;
      _parent = a_parent;
      
      callLoadSuccessListener();
    }
    /**
     * 设置MovieClip数据 
     * @param a_movieClip
     * @param a_parent
     * 
     */		
    public function SetMovieClipData(a_movieClip:MovieClip, a_parent:Resource):void
    {
      _movieClip = a_movieClip;
      _parent = a_parent;
      
      callLoadSuccessListener();
    }
    /**
     * 设置资源包对象 
     * @param a_packObject
     * 
     */		
    private function SetResourcePackObject(a_packObject:Object):void
    {
      _packObject = a_packObject;
    }
    /**
     * 获得SWF数据 
     * @return 
     * 
     */		
    public function getSwfData():ApplicationDomain
    {
      return _appDomain;
    }
    /**
     * 获得BitmapData数据 
     * @return 
     * 
     */		
    public function getBitmapData():BitmapData
    {
      return _bitmapData;
    }
    /**
     * 获得MovieClip数据 
     * @return 
     * 
     */		
    public function getMoveClipData():MovieClip
    {
      return _movieClip;
    }
    
    /**
     * 获得文本资源 
     * @return 
     * 
     */    
    public function getTextData(charSet:String=null):String
    {
      if(!_txtSource) return null;
      _txtSource.position = 0;
      return _txtSource.readMultiByte(_txtSource.length, charSet ||_charset);
    }
    
    /**
     * 获得二进制数据 
     * @return 
     * 
     */    
    public function getByteArrayData():ByteArray
    {
      return _byteArray;
    }
    
    public function getChildDataByType(a_subRes:String, resType:int):*
    {
      if(resType == RESOURCE_TYPE_BITMAP)
        return getSubResAsBitmap(a_subRes);
      if(resType == RESOURCE_TYPE_MOVIECLIP)
        return getSubResAsMovieClip(a_subRes)
        
        return null;
    }
    
    /**
     * 获得SWF资源中的Bitmap子资源 
     * @param a_subRes
     * @return 
     * 
     */		
    public function getSubResAsBitmap(a_subRes:String):BitmapData
    {
      if(isLoaded())
      {
        if(_packObject && _packObject.hasOwnProperty(a_subRes))
        {
          return _packObject[a_subRes] as BitmapData;
        }
        else if(_appDomain && _type == RESOURCE_TYPE_SWF)
        {
          if(_appDomain.hasDefinition(a_subRes))
          {
            var cls:Class = _appDomain.getDefinition(a_subRes) as Class;
            return new cls(1,1) as BitmapData;
          }
        }
      }
      return null;
    }
    /**
     *  获得SWF资源中的MovieClip子资源
     * @param a_subRes
     * @return 
     * 
     */		
    public function getSubResAsMovieClip(a_subRes:String):MovieClip
    {
      if(isLoaded())
      {
        if(_packObject && _packObject.hasOwnProperty(a_subRes))
        {
          return _packObject[a_subRes] as MovieClip;
        }
        else if(_appDomain && _type == RESOURCE_TYPE_SWF)
        {
          if(_appDomain.hasDefinition(a_subRes))
          {
            var cls:Class = _appDomain.getDefinition(a_subRes) as Class;
            return new cls() as MovieClip;
          }
        }
      }
      return null;
    }
    
    /**
     *  获得SWF资源中的SimpleButton子资源
     * @param a_subRes
     * @return 
     * 
     */		
    public function getSubResAsSimpleButton(a_subRes:String):SimpleButton
    {
      if(isLoaded())
      {
        if(_packObject && _packObject.hasOwnProperty(a_subRes))
        {
          return _packObject[a_subRes] as SimpleButton;
        }
        else if(_appDomain && _type == RESOURCE_TYPE_SWF)
        {
          if(_appDomain.hasDefinition(a_subRes))
          {
            var cls:Class = _appDomain.getDefinition(a_subRes) as Class;
            return new cls() as SimpleButton;
          }
        }
      }
      return null;
    }
    
    public function getSubResAsClass(a_subRes:String):Class
    {
      if(isLoaded())
      {
        if(_packObject && _packObject.hasOwnProperty(a_subRes))
        {
          return _packObject[a_subRes] as Class;
        }
        else if(_appDomain && _type == RESOURCE_TYPE_SWF)
        {
          if(_appDomain.hasDefinition(a_subRes))
          {
            var cls:Class = _appDomain.getDefinition(a_subRes) as Class;
            return cls;
          }
        }
      }
      return null;
    }
    
    /**
     *		 获得加载进来swf的根容器
     * 		如果是获取副本的话，请在swf舞台上放置一个movieClip,所有显示内容都包含在
     * 		此swf中.
     * @param isClone 是否获取副本 true 获取副本， false 获取跟对象
     * @return 
     * 
     */		
    public function getObject(isClone:Boolean = false):Object
    {
      if(isLoaded())
      {
        if(_packObject)
        {
          return _packObject;
        }
        else
        {
          switch(_type)
          {
            case RESOURCE_TYPE_SWF:
            {
              if(isClone)
              {
                var mcRoot:MovieClip = _loaderInfo.content as MovieClip;
                var disp:DisplayObject = mcRoot.getChildAt(0);
                var copy:DisplayObject; 
                if(disp)
                {
                  copy = CloneUtil.duplicateDisplayObject(disp);
                }
                else
                {
                  throw new IllegalOperationError("舞台上只可接受一个影片剪辑");
                }
                return copy;
              }
              else
                return _loaderInfo.content;
            }
            case RESOURCE_TYPE_BITMAP:
              return _bitmapData;
            case RESOURCE_TYPE_MOVIECLIP:
              return _movieClip;
          }
        }
      }
      return null;
    }
  }
}