package com.azri.as4j.bean;


/**
 * 获取Bean的工厂
 * @author 破晓
 *
 */
public class BaseBeanFactory implements IBeanFactory {
	/**
	 * @param configName 配置文件地址 
	 */
	public BaseBeanFactory(String configName)
	{
		System.out.println(configName);
	}
	
	@Override
	public Object getBean(String beanName) {
		return null;
	}

	@Override
	public Boolean containsBean(String beanName) {
		return false;
	}

}
