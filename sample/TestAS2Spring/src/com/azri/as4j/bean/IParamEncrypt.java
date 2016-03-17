package com.azri.as4j.bean;


/**
 * 参数加密接口
 * @author 破晓
 *
 */

public interface IParamEncrypt {

	
	/**
	 * 加密
	 * @param param
	 * @return
	 */
	public byte[] encrypt(byte[] param);
	
	/**
	 * 解密
	 * @param param
	 * @return
	 */
	public byte[] decrypt(byte[] param);
	
	/**
	 * 设置外部加密解密器
	 *
	 */
	public void setOutParamEncrypt(IParamEncrypt value);
}
