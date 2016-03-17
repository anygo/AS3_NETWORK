package com.airmyth.net.as3network.util
{
  import flash.utils.Dictionary;
  import flash.utils.describeType;
  import flash.utils.getDefinitionByName;
  import flash.utils.getTimer;

  public class CacheUtil
  {
    private static var classMapCache:Dictionary = new Dictionary();
    
    public static function getClassByName(name:String):Class
    {
      if(classMapCache.hasOwnProperty(name))
        return classMapCache[name];
      else
      {
        var cls:Class = getDefinitionByName(name) as Class;
        classMapCache[name] = cls;
        
        return cls;
      }
    }
    
    private static var modelPropertysCache:Dictionary = new Dictionary();
    
    public static function getPropertysByModel(model:String, instance:Object):Array
    {
      if(modelPropertysCache.hasOwnProperty(model))
        return modelPropertysCache[model];
      
      var xml:XML = describeType(instance);
      var proporty:XMLList = xml.variable;
      var accessor:XMLList = xml.accessor.(@access == "readwrite");
      var accessorRead:XMLList = xml.accessor.(@access == "readonly"); 
      
      var arr:Array = [];
      for each(var item:XML in proporty)
      {
        arr.push({key:item.@name, type:item.@type});
      }
      for each(item in accessor)
      {
        arr.push({key:item.@name, type:item.@type});
      }
      for each(item in accessorRead)
      {
        arr.push({key:item.@name, type:item.@type});
      }
      modelPropertysCache[model] = arr;
      
      return arr;
    }
    
    ////////////////////////////////////////////////////////////////////
    //
    //                     GUID 生成
    //
    ////////////////////////////////////////////////////////////////////
    
    private static var nextGID:uint = 0;
    
    public static function get GUID():String
    {
      return (new Date()).time + "_" + getTimer() + "_" + int(Math.random() * 1000) + "_" + (nextGID++);
    }
  }
}