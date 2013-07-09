using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
///IParamEncrypt 的摘要说明
/// </summary>
public interface IParamEncrypt
{
    /**
     * 加密
     * @param param
     * @return
     */
    byte[] encrypt(byte[] param);

    /**
     * 解密
     * @param param
     * @return
     */
    byte[] decrypt(byte[] param);
}