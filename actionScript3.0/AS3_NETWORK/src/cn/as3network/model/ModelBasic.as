package cn.as3network.model
{
	/**
	 * Model 基类 
	 * @author 破晓
	 * 
	 */	
	public class ModelBasic
	{
		private var _serviceModelName:String;
		
		/**
		 * 构造函数 
		 * @param modelNameSpace
		 * 
		 */		
		public function ModelBasic(modelNameSpace:String)
		{
			_serviceModelName = modelNameSpace;
		}
		
		/**
		 * 获取 与后台对应的Model 命名空间 
		 * @return 
		 * 
		 */		
		public function getModelNameSpace():String
		{
			return _serviceModelName;
		}
	}
}