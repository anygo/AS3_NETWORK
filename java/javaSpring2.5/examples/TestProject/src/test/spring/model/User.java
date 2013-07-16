package test.spring.model;

import cn.as4j.model.ModelBasic;

public class User extends ModelBasic{
	
public User() {
		super("cn.demo.User");
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
