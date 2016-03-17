package com.azri.module.test.vo;

import com.azri.as4j.model.IModelBasic;

public class TestVo implements IModelBasic{
  private String test;

  public String getTest() {
    return test;
  }

  public void setTest(String test) {
    this.test = test;
  }
}
