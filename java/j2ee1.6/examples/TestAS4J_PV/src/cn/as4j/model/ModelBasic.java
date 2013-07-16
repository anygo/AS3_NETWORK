package cn.as4j.model;


/**
 * Model 基类
 * @author 破晓
 *
 */
public class ModelBasic {

	private String _modelName;
	public ModelBasic(String modelNameSpace)
	{
		_modelName = modelNameSpace;
	}
	
	public String getModelNameSpace()
	{
		return _modelName;
	}
}
