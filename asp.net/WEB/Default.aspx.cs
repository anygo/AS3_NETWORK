using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BLL;
using MODEL;
using System.Collections;
using System.IO;
using System.Text;
using as2DotNet;
using System.Reflection;

public partial class _Default : System.Web.UI.Page
{
	private ParamEncoder encoder;
	private ParamDecoder decoder;
    private IParamEncrypt encrypt;
	private DataVO dataVo;
    private ContextUtil context;
    private Stream output;

    protected void Page_Load(object sender, EventArgs e)
    {
        byte[] byteData = null;
        try
        { 
            if (context == null)
            {
                context = ContextUtil.getInstance(Server.MapPath("."));
                encrypt = context.getOuterEncrypt();
            }

            if (encoder == null)
                encoder = ParamEncoder.getInstance();
            if (decoder == null)
                decoder = ParamDecoder.getInstance();

            encoder.outEncoder = context.getOuterResolve();
            decoder.outDecoder = context.getOuterResolve();

            Stream input = Request.InputStream;

            if (input.CanRead)
            {
                byteData = new byte[input.Length];
                input.Read(byteData, 0, (int)input.Length);
                input.Close();
                input.Dispose();

                // 解密
                if (encrypt != null)
                    byteData = encrypt.decrypt(byteData);

                dataVo = decoder.decoder(byteData);
                Type serviceCls = context.getService(context.getServiceNameSpace() + "." + dataVo.ServiceName);

                MethodInfo method = serviceCls.GetMethod(dataVo.MethodName);

                object result = method.Invoke(System.Activator.CreateInstance(serviceCls), dataVo.Param);

                dataVo.Result = result;
                dataVo.ResultStatus = "success";
                byte[] resultData = encoder.encode(dataVo);

                if (encrypt != null)
                    resultData = encrypt.encrypt(resultData);

                output = Response.OutputStream;
                output.Write(resultData, 0, resultData.Length);
                output.Flush();
                output.Close();
                output.Dispose();
            }
            else
            {
            
            }
        }
        catch(Exception exc)
        {
            if (dataVo == null && byteData != null)
               dataVo = decoder.decoder(byteData);
            if (dataVo == null)
               dataVo = new DataVO();
            dataVo.ResultStatus = "error";
            dataVo.ErrorMessage = exc.ToString();
            byte[] resultData = encoder.encode(dataVo);

            if (encrypt != null)
                resultData = encrypt.encrypt(resultData);
            output = Response.OutputStream;
            output.Write(resultData, 0, resultData.Length);
            output.Flush();
            output.Close();
            output.Dispose();
        }
    }
}