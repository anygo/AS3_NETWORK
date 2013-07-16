package cn.as4j.servlet;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.reflect.Method;

import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import cn.as4j.bean.SpringContextUtil;
import cn.as4j.model.DataVo;
import cn.as4j.util.ParamDecoder;
import cn.as4j.util.ParamEncoder;
import cn.as4j.util.ParamType;


@WebServlet("/ControlServlet")
public class ControlServlet extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * Constructor of the object.
	 */
	public ControlServlet() {
		super();
		
		if(encoder == null)
			encoder = ParamEncoder.getInstance();
		if(decoder == null)
			decoder = ParamDecoder.getInstance();
	}

	/**
	 * Destruction of the servlet. <br>
	 */
	public void destroy() {
		super.destroy(); // Just puts "destroy" string in log
		// Put your code here
	}

	/**
	 * The doGet method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to get.
	 * 
	 * @param request the request send by the client to the server
	 * @param response the response send by the server to the client
	 * @throws ServletException if an error occurred
	 * @throws IOException if an error occurred
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		doPost(request, response);
	}
	
	////////////////////////////////////////////////////////////////////////////
	//                                 以下是正文
	////////////////////////////////////////////////////////////////////////////
	
	/**外部解析器Bean的名称*/
	public static final String RESOLVE_BEAN = "resolveBean";
	/**外部加密解密器Bean的名称*/
	public static final String ENCRYPT_BEAN = "encryptBean";
	
	private static SpringContextUtil contextUtil;
	private ParamEncoder encoder;
	private ParamDecoder decoder;
	private DataVo dataVo;
	DataOutputStream dos;
	DataInputStream dis;

	/**
	 * The doPost method of the servlet. <br>
	 *
	 * This method is called when a form has its tag value method equals to post.
	 * 
	 * @param request the request send by the client to the server
	 * @param response the response send by the server to the client
	 * @throws ServletException if an error occurred
	 * @throws IOException if an error occurred
	 */
	@SuppressWarnings({ "rawtypes"})
	public void doPost(HttpServletRequest request, HttpServletResponse response)
	{
		response.setContentType("application/octet-stream");
		byte[] bdata = null;
		try {	
			// 解析请求
			ServletInputStream sis = request.getInputStream();
			int size = request.getContentLength(); 
			bdata = new byte[size];
			sis.read(bdata, 0, size);
			
			//读取spring配置文件
			if(contextUtil == null)
				contextUtil = SpringContextUtil.getInstance();
			
			// 获取外部解析器及加密解密工具
			decoder.outDecrypt = contextUtil.getOuterEncrypt();
			decoder.outDecoder = contextUtil.getOuterResolve();
			encoder.outEncrypt = contextUtil.getOuterEncrypt();
			encoder.outEncoder = contextUtil.getOuterResolve();
			
			dataVo = decoder.decoder(bdata);
			
			// 处理请求
			//获取bean实例
			Object bean = contextUtil.getBean(dataVo.getServiceName());
			
			Object[] parma = dataVo.getParams();
			Method method;
			Object[] result = new Object[1];
			if(parma != null)
			{
				Class[] argsClass = new Class[parma.length];     
				
				for (int i = 0, j = parma.length; i < j; i++) {     
					argsClass[i] = parma[i].getClass();     
					if(ParamType.getTypeMap().containsKey(argsClass[i]))
						argsClass[i] = ParamType.getTypeMap().get(argsClass[i]);
				}  
				method = bean.getClass().getMethod(dataVo.getMethodName(), argsClass); 
				result[0] = method.invoke(bean,parma);
			}
			else
			{
				method = bean.getClass().getMethod(dataVo.getMethodName()); 
				result[0] = method.invoke(bean);
			}
			
			dataVo.setResult(result[0]);
			
			// 响应请求
			
			dataVo.setResultStatus("success");
			dos = encoder.encode(dataVo, response.getOutputStream());
			dos.flush();
			dos.close();

		} catch (Exception e) {
			try {
				if(dataVo == null && bdata != null)
					dataVo = decoder.decoder(bdata);
				if(dataVo == null)
					dataVo = new DataVo();
				dataVo.setResultStatus("error");
				dataVo.setErrorMessage(e.toString());
				dos = encoder.encode(dataVo, response.getOutputStream());
				dos.flush();
				dos.close();
			} catch (Exception e1) {
				e1.printStackTrace();
			}
			e.printStackTrace();
		}
	}

	/**
	 * Initialization of the servlet. <br>
	 *
	 * @throws ServletException if an error occurs
	 */
	public void init() throws ServletException {
		// Put your code here
	}

}
