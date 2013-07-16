package cn.as4j.bean;

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
	public boolean encode(Object param, DataOutputStream dos);
	
	/**
	 * 反序列化
	 * @param dos
	 * @return
	 */
	public Object decode(byte type, DataInputStream dos);
}
