package cn.as3network.util
{
	import cn.as3network.model.DataVo;
	import cn.as3network.model.ModelBasic;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 解析返回值
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class ParamDecoder
	{
		private var _outDecoder:Function;
		
		private var _endian:String = Endian.BIG_ENDIAN;
		/**
		 * 构造函数 
		 * 
		 */		
		public function ParamDecoder()
		{
		}
		
		/**
		 * 解析返回值 
		 * @param stream
		 * @return 
		 * 
		 */		
		public function decode(stream:ByteArray, outDecoder:Function=null):DataVo
		{
			_outDecoder = outDecoder;
			stream.endian = _endian;
			stream.position = 0;
			
			var result:DataVo = new DataVo();
			result.resultStatus = stream.readUTF();
			if(result.resultStatus == "error")
			{
				result.errorMessage = stream.readUTF();
			}
			else
			{
				result.serviceName = stream.readUTF();
				result.methodName = stream.readUTF();
				
				result.result = readAll(stream);
			}
			
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
			else if(type == ParamType.BYTE_ARRAY) return readByteArray(stream);
			else if(type == ParamType.XML) return readXML(stream);
			else if(type == ParamType.DATE) return readDate(stream);
			else if(type == ParamType.ARRAY) return readArray(stream);
			else if(type == ParamType.MODEL) return readModel(stream);
			else if(type == ParamType.OBJECT) return readObject(stream);
			else if(type == ParamType.UNFOUND)
				return stream.readUTF();
			else
				throw new Error("参数格式错误");
			
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
			var dateTime:Array = stream.readUTF().split(" ");
			var date:Array = dateTime[0].split("-");
			var time:Array = dateTime[1].split(":");
			
			return new Date(date[0], date[1], date[2], time[0], time[1], time[2], time.length==4?time[3]:0);
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
		 */		
		public function readModel(stream:ByteArray):ModelBasic
		{
			var modelName:String = stream.readUTF();
			var cls:Class = getDefinitionByName(modelName) as Class;
			var model:ModelBasic = new cls();
			var len:int = stream.readInt();
			
			for(var loop:int=0; loop<len; loop++)
			{
				model[stream.readUTF()] = readAll(stream);
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
		
		/**字节序*/
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

	}
}