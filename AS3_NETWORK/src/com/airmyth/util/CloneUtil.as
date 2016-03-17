package com.airmyth.util
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

  /**
   * 对象克隆 
   * @author sdhd
   * 
   */  
	public class CloneUtil
	{
		public function CloneUtil()
		{
		}
		
		public static function duplicateDisplayObject(target:DisplayObject, autoAdd:Boolean = false):DisplayObject {
			var targetClass:Class = Object(target).constructor;
			var duplicate:DisplayObject = new targetClass() as DisplayObject;
			// duplicate properties
			duplicate.transform = target.transform;
			duplicate.filters = target.filters;
			duplicate.cacheAsBitmap = target.cacheAsBitmap;
			duplicate.opaqueBackground = target.opaqueBackground;
			if (target.scale9Grid) {
				var rect:Rectangle = target.scale9Grid;
				if (Capabilities.version.split(" ")[1] == "9,0,16,0"){
					// Flash 9 bug where returned scale9Grid as twips
					rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				}
				duplicate.scale9Grid = rect;
			}
			// Flash 10 only
			// duplicate.graphics.copyFrom(target.graphics);
			// add to target parent's display list
			// if autoAdd was provided as true
			if (autoAdd && target.parent) {
				target.parent.addChild(duplicate);
			}
			return duplicate;
		}
		
		private static function regtype(tn:String):void {
			if (tn == null || tn == "null" || tn == "int" || tn == "string" || tn == "Number" || tn == "String" || tn == "Boolean" || tn == "Object")return;
			var type:Class;
			try {
				type = getClassByAlias(tn);
			} catch(err:Error) {
			}
			if (type != null)return;
			try {
				type = Class(getDefinitionByName(tn));
			} catch(err:Error) {
				return;
			}
			if (type == null)return;
			registerClassAlias(tn, type);
		}
		
		private static function registerClass(source:*):void {
			var tn:String = getQualifiedClassName(source);
			regtype(tn);
			if(tn=="Array"||tn=="flash.utils::Dictionary"){
				for(var ele:String in source){
					registerClass(source[ele]);
				}
			}
			var dxml:XML = describeType(source);
			for each(var acc:XML in dxml.accessor) {
				registerClass(source[acc.@name]);
			}
			for each(var acc1:XML in dxml.variable) {
				registerClass(source[acc1.@name]);
			}
			for each(var acc2:XML in dxml.implementsInterface) {
				regtype(acc2.@type);
			}
			regtype(dxml.extendsClass.@type);
		}
		
		/**
		 * 方 法 名：clone
		 * 方法功能：深克隆方法
		 * 创建日期：2010-11-12
		 */
		public static function baseClone(source:*):* {
			registerClass(source);
			var byteArray:ByteArray=new ByteArray();
			byteArray.writeObject(source);
			byteArray.position=0;
			return byteArray.readObject();
		}
		
	}
}