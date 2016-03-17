package com.azri.as4j.model;


/**
 * 数据
 * @author 破晓
 *
 */
public class DataVo {
	/** 通信ID */
	private String ACUID = "";
	/** 服务名称 */
	private String serviceName;
	/** 调用的方法名称 */
	private String methodName;
	/** 参数列表 */
	private Object[] params;
	
	/** 执行状态（error/success） */
	private String resultStatus;
	/** 返回值 */
	private Object result;
	
	/** 异常信息 */
	private String errorMessage;
	
	
	public String getResultStatus() {
		return resultStatus;
	}
	public void setResultStatus(String resultStatus) {
		this.resultStatus = resultStatus;
	}
	public Object getResult() {
		return result;
	}
	public void setResult(Object result) {
		this.result = result;
	}
	public String getErrorMessage() {
		return errorMessage;
	}
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}
	public String getServiceName() {
		return serviceName;
	}
	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}
	public String getMethodName() {
		return methodName;
	}
	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}
	public Object[] getParams() {
		return params;
	}
	public void setParams(Object[] params) {
		this.params = params;
	}
	public String getACUID() {
		return ACUID;
	}
	public void setACUID(String aCUID) {
		ACUID = aCUID;
	}
}
