package test.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.airmyth.bean.ContextUtil;

import test.module.TestVo;
import test.module.User;


/**
 * TopService
 * 
 */
public class TopService {
   
  public String callTest()
  {
	  return "success";
  }
  public List<Map<String, Object>> getList(List<Map<String, Object>> lst)
  {
	  List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
	  Map<String, Object> map;
	  for(Map<String, Object> item :lst)
	  {
		  map = new HashMap<String, Object>();
		  map.put("name", item.get("name"));
		  map.put("size", Integer.parseInt(item.get("size").toString()) + 1);
		  result.add(map);
	  }
	  
	  return result;
  }
  
  public TestVo testHead(TestVo vo)
  {
	  String head = ContextUtil.getRequest().getHeader("tokenHead");
	  vo.setTest(head + Math.random());
	    
	    return vo;
  }
  
  public User findTopView(User u)
  {
	  u.setNickName("ttttttt" + Math.random());
	  
	  return u;
  }
  
  public double getSum(int p1, double p2)
  {
	  return p1 + p2;
  }
}
