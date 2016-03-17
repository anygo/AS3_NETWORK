package com.airmyth.net.as3network.net.http
{
  import com.airmyth.net.as3network.model.Session;
  import com.airmyth.net.as3network.util.CacheUtil;

  public class AbstractChannelManager
  {
    /** 待命通道 */
    private var channels:Array = [];
    
    /** 待执行任务 */
    private var tasks:Array = [];
    
    private static var _instance:AbstractChannelManager;
    
    public static function getInstance():AbstractChannelManager
    {
      if(!_instance)
        _instance = new AbstractChannelManager();
      
      return _instance;
    }
    
    public function AbstractChannelManager()
    {
      channels.push(new AbstractChannel(), 
                               new AbstractChannel(),
                               new AbstractChannel());
    }
    
    /**
     * 添加任务 
     * @param task
     * @return 通信ID
     */    
    public function addTask(task:Session):void
    {
      task.data.ACUID = CacheUtil.GUID;
      tasks.push(task);
      
      doNextTask();
    }
    
    public function doNextTask():void
    {
      if(channels.length == 0) return;
      if(tasks.length == 0) return;
      
	  var task:Session = tasks.shift();
	  if(task.canRun)
		  AbstractChannel(channels.pop()).send(task);
    }
    
    public function pushChannel(c:AbstractChannel):void
    {
      channels.push(c);
    }
  }
}