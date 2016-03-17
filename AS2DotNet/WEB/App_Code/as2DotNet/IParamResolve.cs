using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;

/// <summary>
///IParamResolve 的摘要说明
/// </summary>
public interface IParamResolve
{
    /**
	 * 序列化
	 * @param param
	 * @param dos
	 * @return
	 */
    Boolean encode(Object param, BinaryWriter dos);

    /**
     * 反序列化
     * @param dos
     * @return
     */
    Object decode(byte type, BinaryReader dos);
}