# -*- coding: UTF-8 -*-
# 使用IE webdriver进行动态网页的抓取
import sys
from bs4 import BeautifulSoup
from selenium import webdriver
from time import sleep
from selenium.webdriver.support.ui import WebDriverWait
#from selenium.webdriver.common.by import By
#from selenium.webdriver.support import expected_conditions as EC
import requests
browser = webdriver.Ie()
browser.get("http://cs.scu.edu.cn/index/xytz.htm")
wait = WebDriverWait(browser, 10)
sleep(8)
data=open("data1.html",'wb')
data.write(browser.page_source.encode("utf-8"))
data.close()
browser.close()
browser.quit()
sys.exit(0)