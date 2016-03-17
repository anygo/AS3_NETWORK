package com.airmyth.net.as3network.event
{
	import flash.events.Event;
	
	/**
	 * 上传文件 事件 
	 * @author 破晓
	 * 
	 */	
	public class UploadEvent extends Event
	{
		/**文件选择完毕时触发*/
		public static const SELECTED:String = "uploadFileSelected";
		/**上传出错时触发*/
		public static const ERROR:String = "uploadFileError";
		/**上传完成时触发*/
		public static const COMPLETE:String = "uploadFileComplete";
		/**上传完成时触发*/
		public static const UPLOAD_COMPLETE_DATA:String = "uploadFileUploadCompleteData";
		/**上传进度改变时触发*/
		public static const PROGRESS:String = "uploadFileProgress";
		
		private var _data:Object;
		
		/**
		 * 构造函数 
		 * @param type
		 * @param data
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function UploadEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_data = data;
		}

		/**
		 * 事件数据 
		 * <br>
		 * 结构如下:<br>
		 * <table bgcolor="#eeeeee" border="1">
		 * <tr><td><div align="center"><strong>事件名称</strong></div></td><td><div align="center"><strong>类型</strong></div></td><td><div align="center"><strong>data数据</strong></div></td></tr>
		 * <tr><td>SELECTED</td><td>FileReference</td><td>data.file</td></tr>
		 * <tr><td>ERROR</td><td>IOErrorEvent</td><td>data.error</td></tr>
		 * <tr><td>COMPLETE</td><td>无</td><td>null</td></tr>
		 * <tr><td>PROGRESS</td><td>ProgressEvent</td><td>data.progress</td></tr>
		 * </table>
		 * @return 
		 * 
		 */		
		public function get data():Object
		{
			return _data;
		}

		public function set data(value:Object):void
		{
			_data = value;
		}

    override public function clone():Event
    {
      return new UploadEvent(type, data);
    }
	}
}