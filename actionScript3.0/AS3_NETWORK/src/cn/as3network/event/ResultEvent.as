package cn.as3network.event
{
	import cn.as3network.model.DataVo;
	
	import flash.events.Event;
	
	/**
	 * 回调成功
	 * @author 破晓
	 * 
	 */	
	public class ResultEvent extends Event
	{
		/**调用后台方法成功时触发*/
		public static const RESULT_EVENT:String = "A2JResultEvent";
		
		private var _result:DataVo;
		
		/**
		 * 构造函数 
		 * @param resultData 返回值数据
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function ResultEvent(resultData:DataVo, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(RESULT_EVENT, bubbles, cancelable);
			
			_result = resultData;
		}

		/**
		 * 返回值数据 
		 * @return 
		 * 
		 */		
		public function get result():DataVo
		{
			return _result;
		}
	}
}