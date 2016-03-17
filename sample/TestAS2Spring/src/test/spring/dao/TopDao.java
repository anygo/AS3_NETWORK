package test.spring.dao;

import test.spring.model.User;

/**
 * 接口名：TopDao
 */
public interface TopDao {
  
  /**
   * 在主页面显示登陆者信息
   * @param userID 输入登录用户ID
   * @return 当前登陆者信息
   */
  public User findTopView(User user);
}
