package cn.as4j.bean;

import org.springframework.beans.factory.BeanFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;


/**
 * 获取Bean的工厂
 * @author 破晓
 *
 */
public class AS2JAVABeanFactory implements IBeanFactory {

	private static BeanFactory bf;
	
	/**
	 * @param configName 配置文件地址 applicationContext.xml
	 */
	public AS2JAVABeanFactory(String configName)
	{
		//读取spring配置文件
		if(bf == null)
			bf = new ClassPathXmlApplicationContext(configName);
	}
	
	@Override
	public Object getBean(String beanName) {
		return bf.getBean(beanName);
	}

	@Override
	public Boolean containsBean(String beanName) {
		return bf.containsBean(beanName);
	}

}
