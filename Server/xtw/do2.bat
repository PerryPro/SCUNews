@echo off
start cmd /k "cd/d C:\news\xtw&& python get_html_xtw.py&&exit"
ping -n 30 127.0.0.1>nul
start cmd /k "cd/d C:\news\xtw&& php get_news_xtw.php&&exit"
start cmd /k "cd/d C:\news\jsjxy&& python get_html_jsjxy.py&&exit"
ping -n 30 127.0.0.1>nul
start cmd /k "cd/d C:\news\jsjxy&& php get_news_jsjxy.php&&exit"
exit