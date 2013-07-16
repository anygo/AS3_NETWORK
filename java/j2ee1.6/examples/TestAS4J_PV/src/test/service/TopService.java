package test.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
}
