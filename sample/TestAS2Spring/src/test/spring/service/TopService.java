package test.spring.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.azri.module.test.vo.TestVo;

import test.spring.dao.TopDao;
import test.spring.model.User;

/**
 * TopService
 * 
 */
public class TopService {
	private TopDao topDao;

	public void setTopDao(TopDao topDao) {
		this.topDao = topDao;
	}

	/**
	 *
	 * @param strUserID
	 * @return
	 */
	public User findTopView(User user) {

		return topDao.findTopView(user);
	}

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

	public TestVo test(TestVo vo)
	{
		vo.setTest(vo.getTest() + Math.random());

		return vo;
	}
}
