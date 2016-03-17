package cn.demo
{
	import com.azri.net.as3network.util.IParamResolve;
	import com.azri.net.as3network.util.ParamDecoder;
	import com.azri.net.as3network.util.ParamEncoder;
	import com.azri.net.as3network.util.ParamType;
	
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * 
	 * @author 破晓
	 * 
	 */	
	public class EncoderArrayCollection implements IParamResolve
	{
		private var encoder:ParamEncoder;
		private var decoder:ParamDecoder;
		private var _outResolve:IParamResolve;
		
		public function EncoderArrayCollection()
		{
			encoder = new ParamEncoder();
			decoder = new ParamDecoder();
		}
		
		/**
		 * 自定义类型 请使用 50-100 内的数字 
		 * @param param
		 * @param stream
		 * @return 
		 * 
		 */		
		public function encode(param:*, stream:ByteArray):Boolean
		{
			if(_outResolve && _outResolve.encode(param, stream)) return true;
				
			if(param as ArrayCollection)
			{
				stream.writeByte(ParamType.ARRAY);  // 自定义类型 请使用 50-100 内的数字 
				stream.writeInt(param.length);
				
				for each(var item:* in param)
				{
					encoder.writeAll(item, stream);
				}
				
				return true;
			}
			return false;
		}
		
		public function decode(type:int, stream:ByteArray):*
		{
			if(_outResolve) 
			{
				var re:* = _outResolve.decode(type, stream);
				if(re != null) return re;
			}
			
			if(type == ParamType.ARRAY)
			{
				var arr:ArrayCollection = new ArrayCollection();
				var len:int = stream.readInt();
				for(var loop:int=0; loop<len; loop++)
				{
					arr.addItem(decoder.readAll(stream));
				}
				
				return arr;
			}
			return null;
		}
		
		public function set outParamResolve(value:IParamResolve):void
		{
			_outResolve = value;
		}
		
	}
}