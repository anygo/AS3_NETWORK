package test.spring.impl;

import test.spring.dao.TopDao;
import test.spring.model.User;

/**
 * 类名  ：TopDaoImpl
 */
public class TopDaoImpl implements TopDao {
  
  /**
   * 获取登录者信息
   * @param userID
   * @return List
   */
  public User findTopView(User user) {    
	  user.setNickName("测试1");
    return user;
  }
}