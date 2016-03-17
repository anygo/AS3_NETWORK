package com.airmyth.net.as3network.util
{
	import com.airmyth.IDestroy;
	import com.airmyth.net.as3network.model.DataVo;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * 解析返回值
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class ParamDecoder implements IDestroy
	{
		
		private var _outDecoder:Function;
		
		private var _endian:String = Endian.BIG_ENDIAN;
		
		private var _getModelHandler:Function;
		
		private static var _instance:ParamDecoder;
		
		public static function get instance():ParamDecoder
		{
			_instance ||= new ParamDecoder();		
			
			return _instance;
		}
		
		/**
		 * 解析返回值 
		 * @param stream
		 * @param endian 字节序
		 * @param outDecoder
		 * @param getModel
		 * @return 
		 * 
		 */		
		public function decode(stream:ByteArray, endian:String=Endian.BIG_ENDIAN, outDecoder:Function=null, getModel:Function=null):DataVo
		{
			_endian = endian;
			_outDecoder = outDecoder;
			_getModelHandler = getModel;
			stream.endian = _endian;
			stream.position = 0;
			
			var result:DataVo = new DataVo();
			if(stream.length == 0)
			{
				result.resultStatus = "error";
				return result;
			}
			
//      if(stream.length != stream.readUnsignedInt())
//        throw new Error("丢包了");
      
			result.ACUID = stream.readUTF();	
			result.serviceName = stream.readUTF();
			result.methodName = stream.readUTF();
			result.resultStatus = stream.readUTF();
			if(result.resultStatus == "error")
				result.errorMessage = stream.readUTF();
			else
				result.result = readAll(stream);
			
			destroy();
			return result;
		}
		
		/**
		 * 读取 任意类型 数据 
		 * 包括 :<br>
		 * <li>null</li>
		 * <li>Boolean</li>
		 * <li>int</li>
		 * <li>String</li>
		 * <li>ByteArray</li>
		 * <li>Number</li>
		 * <li>Array</li>
		 * <li>XML</li>
		 * <li>Date</li>
		 * <li>ModelBasic</li>
		 * <li>Object </li>
		 * <li>通过IParamResolve接口构建的自定义类型</li> 
		 * @param stream
		 * @return 
		 * 
		 * @see ParamType
		 * @see IParamResolve
		 */		
		public function readAll(stream:ByteArray):*
		{
			var out:*;
			var type:int = stream.readByte();
			if(type == ParamType.NULL) return null;
			else if(_outDecoder != null && (out = _outDecoder(type, stream), out != null)) return out;
			else if(type == ParamType.BOOLEAN) return readBoolean(stream);
			else if(type == ParamType.INT) return readInt(stream);
			else if(type == ParamType.NUMBER) return readNumber(stream);
			else if(type == ParamType.STRING) return readString(stream);
			else if(type == ParamType.ARRAY) return readArray(stream);
			else if(type == ParamType.MODEL) return readModel(stream);
			else if(type == ParamType.DATE) return readDate(stream);
			else if(type == ParamType.UINT) return readUInt(stream);
			else if(type == ParamType.USHORT) return readUShort(stream);
			else if(type == ParamType.SHORT) return readShort(stream);
			else if(type == ParamType.BYTE) return readByte(stream);
			else if(type == ParamType.UBYTE) return readUByte(stream);
			else if(type == ParamType.FLOAT) return readFloat(stream);
			else if(type == ParamType.BYTE_ARRAY) return readByteArray(stream);
			else if(type == ParamType.XML) return readXML(stream);
			else if(type == ParamType.DICTIONARY) return readObject(stream);
			else if(type == ParamType.OBJECT) return readObject(stream);
			else if(type == ParamType.UNFOUND)
				return stream.readUTF();
			else
				throw new Error("参数格式错误,未找到类型为：【" + type + "】的参数解析方式");
			
			return null;
		}
		
		/**
		 * 读取  Boolean 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readBoolean(stream:ByteArray):Boolean
		{
			return stream.readBoolean();
		}
		
		/**
		 * 读取  int 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readInt(stream:ByteArray):int
		{
			return stream.readInt();
		}
		
		/**
		 * 读取  uint 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readUInt(stream:ByteArray):uint
		{
			return stream.readUnsignedInt();
		}
		
		/**
		 * 读取  UShort 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readUShort(stream:ByteArray):uint
		{
			return stream.readUnsignedShort();
		}
		
		/**
		 * 读取  Short 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readShort(stream:ByteArray):int
		{
			return stream.readShort();
		}
		
		/**
		 * 读取  UByte 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readUByte(stream:ByteArray):uint
		{
			return stream.readUnsignedByte();
		}
		
		/**
		 * 读取  Float 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readFloat(stream:ByteArray):Number
		{
			return stream.readFloat();
		}
		
		/**
		 * 读取  Byte 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readByte(stream:ByteArray):int
		{
			return stream.readByte()
		}
		
		/**
		 * 读取  Number 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readNumber(stream:ByteArray):Number
		{
			return stream.readDouble();
		}
		
		/**
		 * 读取  String 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readString(stream:ByteArray):String
		{
			return stream.readUTF();
		}
		
		/**
		 * 读取  ByteArray 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readByteArray(stream:ByteArray):ByteArray
		{
			var len:int = stream.readInt();
			var ba:ByteArray = new ByteArray();
			ba.endian = _endian;
			stream.readBytes(ba, 0, len);
			return ba;
		}
		
		/**
		 * 读取  XML 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readXML(stream:ByteArray):XML
		{
			return new XML(stream.readUTF());
		}
		
		/**
		 * 读取  Date 类型数据
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readDate(stream:ByteArray):Date
		{
			//			var dateTime:Array = stream.readUTF().split(" ");
			//			var date:Array = dateTime[0].split("-");
			//			var time:Array = dateTime[1].split(":");
			//      new Date(date[0], date[1], date[2], time[0], time[1], time[2], time.length==4?time[3]:0);
			return new Date(stream.readDouble());
		}
		
		/**
		 * 读取Array 
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readArray(stream:ByteArray):Array
		{
			var arr:Array = [];
			var len:int = stream.readInt();
			for(var loop:int=0; loop<len; loop++)
			{
				arr.push(readAll(stream));
			}
			
			return arr;
		}
		
		/**
		 * 读取Model 
		 * @param stream
		 * @return 
		 * 
		 * @see ModelBasic
		 */		
		public function readModel(stream:ByteArray):Object
		{
			var modelName:String = stream.readUTF();
			var cls:Class;
			if(_getModelHandler != null)
				cls = _getModelHandler(modelName);
			else
				cls = CacheUtil.getClassByName(modelName);
			if(!cls)
				return readObject(stream);
			
			var model:Object = new cls();
			var len:int = stream.readInt();
			
			var pro:String;
			for(var loop:int=0; loop<len; loop++)
			{
				pro = stream.readUTF();
				if(model.hasOwnProperty(pro))
					model[pro] = readAll(stream);
				else
				{
					var obj:Object = readAll(stream);
					trace("warning:###ModelDecoder：" + modelName + "中变量" + pro + "未定义!! 其值为：" + obj);
				}
			}
			
			return model;
		}
		
		/**
		 * 读取Object 
		 * @param stream
		 * @return 
		 * 
		 */		
		public function readObject(stream:ByteArray):Object
		{
			var obj:Object = {};
			var len:int = stream.readInt();
			for(var loop:int=0; loop<len; loop++)
			{
				obj[stream.readUTF()] = readAll(stream);
			}
			
			return obj;
		}
		
		/**
		 * 字节序
		 * @return 
		 * 
		 * @see ByteArray.endian
		 */	
		public function get endian():String
		{
			return _endian;
		}
		
		/**
		 * @private
		 */
		public function set endian(value:String):void
		{
			if(value == Endian.BIG_ENDIAN || value == Endian.LITTLE_ENDIAN)
				_endian = value;
		}
		
		public function destroy():void
		{
			_outDecoder = null;
			_getModelHandler = null;
		}
		
	}
}