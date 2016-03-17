package test.spring.model;

import com.azri.as4j.model.IModelBasic;

public class User implements IModelBasic{
	
public User() {
		super();
	}
private String username;
private String password;
private String nickName;

public String getNickName() {
	return nickName;
}
public void setNickName(String nickName) {
	this.nickName = nickName;
}
public String getUsername() {
	return username;
}
public void setUsername(String username) {
	this.username = username;
}
public String getPassword() {
	return password;
}
public void setPassword(String password) {
	this.password = password;
}
}
