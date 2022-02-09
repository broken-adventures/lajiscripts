from urllib.request import urlopen
#导入urlopen函数
#读取网页内容，如果网页中又中文要用“utf-8”解码
html = urlopen("http://172.67.199.254/cdn-cgi/trace").read().decode('utf-8')
print(html)