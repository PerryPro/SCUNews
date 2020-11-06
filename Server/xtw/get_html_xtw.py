# -*- coding: UTF-8 -*-
import sys
from bs4 import BeautifulSoup
from selenium import webdriver
from time import sleep
from selenium.webdriver.support.ui import WebDriverWait
#from selenium.webdriver.common.by import By
#from selenium.webdriver.support import expected_conditions as EC
import requests
browser = webdriver.Ie()
browser.get("http://tuanwei.scu.edu.cn/index/gg.htm")
wait = WebDriverWait(browser, 10)
sleep(8)
data=open("data1.html",'wb') 
# print('这是个测试',file=data)
#print(type(browser.page_source))
data.write(browser.page_source.encode("utf-8"))
data.close()
browser.close()
browser.quit()
sys.exit(0)