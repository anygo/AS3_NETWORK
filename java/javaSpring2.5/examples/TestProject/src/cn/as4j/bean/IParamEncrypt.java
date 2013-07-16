package cn.as4j.bean;


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
}
