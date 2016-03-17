package com.airmyth.bean;

import java.io.DataInputStream;
import java.io.DataOutputStream;


/**
 * 外部解析器接口
 * @author Administrator
 *
 */
public interface IParamResolve {

	
	/**
	 * 序列化
	 * @param param
	 * @param dos
	 * @return
	 */
	public boolean encode(Object param, DataOutputStream dos) throws Exception;
	
	/**
	 * 反序列化
	 * @param dos
	 * @return
	 * @throws Exception 
	 */
	public Object decode(byte type, DataInputStream dos) throws Exception;
	
	/**
	 * 设置外部解析器
	 */
	public void setOutParamResolve(IParamResolve value);
}
