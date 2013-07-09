package cn.as3network.util
{
	import cn.as3network.model.DataVo;
	import cn.as3network.model.ModelBasic;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.describeType;

	/**
	 * 序列化参数 
	 * @author 破晓(QQ群:272732356)
	 * 
	 */	
	public class ParamEncoder
	{
		private var _outEncoder:Function;
		
		private var _endian:String = Endian.BIG_ENDIAN;
		
		/**
		 * 构造函数 
		 * 
		 */		
		public function ParamEncoder()
		{
		}
		
		/**
		 * 序列化请求数据 
		 * @param value
		 * @return 
		 * 
		 */		
		public function encode(value:DataVo, outEncoder:Function=null):ByteArray
		{
			if(!value) return null;
			_outEncoder = outEncoder;
			
			var stream:ByteArray = new ByteArray();
			stream.endian = _endian;
			stream.writeUTF(value.serviceName);   // 写入服务名称
			stream.writeUTF(value.methodName);// 写入函数名称
			
			// 写入参数
			var params:Array = value.params;
			if(params == null || params.length == 0) 
			{
				stream.writeInt(0);
			}
			else
			{
				stream.writeInt(params.length);  // 参数个数
				for each(var p:* in params)
				{
					writeAll(p, stream);
				}
			}
			
			stream.position = 0;
			
			return stream;
		}
		
		/**
		 * 写入 任意类型 参数 
		 * 包括 :<br>
		 * <li>null</li>
		 * <li>undefined</li>
		 * <li>Boolean</li>
		 * <li>int</li>
		 * <li>uint</li>
		 * <li>String</li>
		 * <li>ByteArray</li>
		 * <li>Number</li>
		 * <li>Array</li>
		 * <li>XML</li>
		 * <li>Date</li>
		 * <li>ModelBasic</li>
		 * <li>Dictionary</li>
		 * <li>Object </li>
		 * <li>通过IParamResolve接口构建的自定义类型</li>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeAll(param:*, stream:ByteArray):void
		{
			if(param == null || param == undefined) writeNull(stream);
			else if(_outEncoder != null && _outEncoder(param, stream)) return;
			else if(param is Boolean)    writeBoolean(param, stream);
			else if(param is int)             writeInt(param, stream);
			else if(param is uint)           writeUint(param, stream);
			else if(param is String)        writeString(param, stream);
			else if(param is ByteArray) writeByteArray(param, stream);
			else if(param is Number)    writeNumber(param, stream);
			else if(param is Array)         writeArray(param, stream);
			else if(param is XML)          writeXML(param, stream);
			else if(param is Date)           writeDate(param, stream);
			else if(param is ModelBasic) writeModel(param, stream);
			else if(param is Dictionary) writeDictionary(param, stream);
			else if(param is Object)       writeObject(param, stream);
			else
			{
				stream.writeByte(ParamType.UNFOUND);
				stream.writeUTF(param + "");
			}
		}
		
		/**
		 * 写入 null （当值为 null 或 undefined 时） <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.NULL</td></tr>
		 * </table>
		 * @param stream
		 * 
		 */		
		public function writeNull(stream:ByteArray):void
		{
			stream.writeByte(ParamType.NULL);
		}
		
		/**
		 * 写入  Boolean 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.BOOLEAN</td></tr>
		 * <tr><td>参数值</td><td>Boolean</td><td>param</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeBoolean(param:Boolean, stream:ByteArray):void
		{
			stream.writeByte(ParamType.BOOLEAN);
			stream.writeBoolean(param);
		}
		
		/**
		 * 写入 int 类型参数 
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.INT</td></tr>
		 * <tr><td>参数值</td><td>int</td><td>param</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeInt(param:int, stream:ByteArray):void
		{
			stream.writeByte(ParamType.INT);
			stream.writeInt(param);
		}
		
		/**
		 *  写入 uint 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.UINT</td></tr>
		 * <tr><td>参数值</td><td>int</td><td>param</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeUint(param:uint, stream:ByteArray):void
		{
			stream.writeByte(ParamType.UINT);
			stream.writeInt(param);
		}
		
		/**
		 *  写入 String 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.STRING</td></tr>
		 * <tr><td>参数值</td><td>String</td><td>param</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeString(param:String, stream:ByteArray):void
		{
			stream.writeByte(ParamType.STRING);
			stream.writeUTF(param);
		}
		
		/**
		 *  写入 ByteArray 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.BYTE_ARRAY</td></tr>
		 * <tr><td>ByteArray长度</td><td>int</td><td>param.length</td></tr>
		 * <tr><td>参数值</td><td>ByteArray</td><td>param</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeByteArray(param:ByteArray, stream:ByteArray):void
		{
			stream.writeByte(ParamType.BYTE_ARRAY);
			stream.writeInt(param.length);
			stream.writeBytes(param, 0, param.length);
		}
		
		/**
		 *  写入 Number 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.NUMBER</td></tr>
		 * <tr><td>参数值</td><td>Double</td><td>param</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeNumber(param:Number, stream:ByteArray):void
		{
			stream.writeByte(ParamType.NUMBER);
			if(isNaN(param)) param = 0;
			stream.writeDouble(param);
		}
		
		/**
		 * 写入 Array 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.ARRAY</td></tr>
		 * <tr><td>Array长度</td><td>Double</td><td>param.length</td></tr>
		 * <tr><td>参数值</td><td>[＊, ＊, ＊...]</td><td>[item, item, item...]</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeArray(param:Array, stream:ByteArray):void
		{
			stream.writeByte(ParamType.ARRAY);
			stream.writeInt(param.length);
			for each(var obj:* in param)
			{
				writeAll(obj, stream);
			}
		}
		
		/**
		 *  写入 XML 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.XML</td></tr>
		 * <tr><td>参数值</td><td>String</td><td>param.toXMLString()</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeXML(param:XML, stream:ByteArray):void
		{
			stream.writeByte(ParamType.XML);
			stream.writeUTF(param.toXMLString());
		}
		
		/**
		 *  写入 Date 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.DATE</td></tr>
		 * <tr><td>参数值</td><td>String</td><td>格式：YYYY-MM-DD HH:min:ss:ms</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeDate(param:Date, stream:ByteArray):void
		{
			var date:Date = param as Date;
			var str:String = date.fullYear + "-" + date.month + "-" + date.date + " " +  date.hours + ":" + date.minutes + ":" + date.seconds + ":" + date.milliseconds;
			
			stream.writeByte(ParamType.DATE);
			stream.writeUTF(str);
		}
		
		/**
		 * 写入 Model 类型参数 
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.MODEL</td></tr>
		 * <tr><td>后台对应类</td><td>String</td><td>param.getModelNameSpace()</td></tr>
		 * <tr><td>属性个数</td><td>int</td><td></td></tr>
		 * <tr><td>参数值</td><td>[{String, ＊}...]</td><td>[{key, value}...]</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeModel(param:ModelBasic, stream:ByteArray):void
		{
			stream.writeByte(ParamType.MODEL);
			stream.writeUTF(param.getModelNameSpace());
			
			var proporty:XMLList = describeType(param).variable;
			
			stream.writeInt(proporty.length());
			
			var key:String;
			for each(var item:XML in proporty)
			{
				key = item.@name;
				stream.writeUTF(key);
				writeAll(param[key], stream);
			}
		}
		
		/**
		 *  写入 Dictionary 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.DICTIONARY</td></tr>
		 * <tr><td>属性个数</td><td>int</td><td></td></tr>
		 * <tr><td>参数值</td><td>[{String, ＊}...]</td><td>[{key, value}...]</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeDictionary(param:Dictionary, stream:ByteArray):void
		{
			stream.writeByte(ParamType.DICTIONARY);
			buildObject(param, stream);
		}
		
		/**
		 *  写入 Object 类型参数
		 *  <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>值</strong></div></td></tr>
		 * <tr><td>参数类型</td><td>Byte</td><td>ParamType.OBJECT</td></tr>
		 * <tr><td>属性个数</td><td>int</td><td></td></tr>
		 * <tr><td>参数值</td><td>[{String, ＊}...]</td><td>[{key, value}...]</td></tr>
		 * </table>
		 * @param param
		 * @param stream
		 * 
		 */		
		public function writeObject(param:Object, stream:ByteArray):void
		{
			stream.writeByte(ParamType.OBJECT);
			buildObject(param, stream);
		}
		
		/**
		 * 序列化Object类型  
		 * @param param
		 * @param stream
		 * 
		 */		
		private function buildObject(param:Object, stream:ByteArray):void
		{
			var typePos:uint = stream.position;
			var len:int = 0;
			stream.writeInt(0);
			for(var key:String in param)
			{
				stream.writeUTF(key);
				writeAll(param[key], stream);
				
				len++;
			}
			var dataPos:uint = stream.position;
			stream.position = typePos;
			stream.writeInt(len);
			
			stream.position = dataPos;
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