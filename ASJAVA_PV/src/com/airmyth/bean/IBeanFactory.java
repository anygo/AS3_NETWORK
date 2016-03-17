package com.airmyth.bean;

/**
 * 生成Bean的工厂类接口
 * @author 破晓
 *
 */
public interface IBeanFactory {
	
	/**
	 * 根据名称获取Bean
	 * @param beanName
	 * @return
	 */
	public Object getBean(String beanName);
	
	
	/**
	 * 判断Bean是否存在
	 * @param beanName
	 * @return
	 */
	public Boolean containsBean(String beanName);
}
