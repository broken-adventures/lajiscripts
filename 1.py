import requests
from bs4 import BeautifulSoup as bs
from fake_useragent import UserAgent
import random
from telegram.ext import Updater,CommandHandler

updater = Updater("<YOUR_TOKEN>")
dispatcher = updater.dispatcher

def getParams():
    ua = UserAgent()
    params = dict(
        headers = {'User-Agent': ua.random},
    )
    return params

def getSoup(url,encoding="utf-8",**params):
    reponse = requests.get(url,**params)
    reponse.encoding = encoding
    soup = bs(reponse.text,'lxml')
    return soup

def getWebpage():
    global eu1,eu2,eu3,eu4,eu5,eu6,eu7,eu8,eu9,eu10,eumid1,euovz,id1,usla2,allvps
    params = getParams()
    soup = getSoup("https://hax.co.id/data-center/",**params)
    allVPS = soup.find_all('h1')
    eu1 = allVPS[0].string.replace(' VPS', '')
    eu2 = allVPS[1].string.replace(' VPS', '')
    eu3 = allVPS[2].string.replace(' VPS', '')
    eu4 = allVPS[3].string.replace(' VPS', '')
    eu5 = allVPS[4].string.replace(' VPS', '')
    eu6 = allVPS[5].string.replace(' VPS', '')
    eu7 = allVPS[6].string.replace(' VPS', '')
    eu8 = allVPS[7].string.replace(' VPS', '')
    eu9 = allVPS[8].string.replace(' VPS', '')
    eu10 = allVPS[9].string.replace(' VPS', '')
    eumid1 = allVPS[10].string.replace(' VPS', '')
    id1 = allVPS[11].string.replace(' VPS', '')
    usla2 = allVPS[12].string.replace(' VPS', '')
    euovz = allVPS[13].string.replace(' VPS', '')
    allvps = allVPS[14].string.replace(' VPS', '')

def start(update, context):
    context.bot.send_message(chat_id=update.effective_chat.id, text="欢迎使用Hax库存查询监控bot！\n我能够帮你拿到hax官网上的库存信息，并把他们发送到你的Telegram会话中\n输入 /help 获取帮助列表\nGithub: Misaka-blog    TG: @misakanetcn")

def help(update, context):
    context.bot.send_message(chat_id=update.effective_chat.id, text="Hax 库存查询监控BOT 帮助菜单\n/help 显示本菜单\n/get 获取当前库存情况\n/ping 检测bot存活状态")

def ping(update, context):
    context.bot.send_message(chat_id=update.effective_chat.id, text="Pong~")

def get(update, context):
    getWebpage()
    context.bot.send_message(chat_id=update.effective_chat.id, text="我获取到网页了！下面是Hax VPS目前库存情况：\nEU-1: "+eu1+"\nEU-2: "+eu2+"\nEU-3: "+eu3+"\nEU-4: "+eu4+"\nEU-5: "+eu5+"\nEU-6: "+eu6+"\nEU-7: "+eu7+"\nEU-8: "+eu8+"\nEU-9: "+eu9+"\nEU-10: "+eu10+"\nEU-Mid-1: "+eumid1+"\nID-1: "+id1+"\nUS-LA2: "+usla2+"\nEU-OpenVZ: "+euovz+"\n开通的VPS: "+allvps+"\nNote: EU1-EU10、EU-Mid-1为KVM区，ID-1、US-LA2为LXC区")

Start = CommandHandler('start', start)
Ping = CommandHandler('ping', ping)
Get = CommandHandler('get', get)
Help = CommandHandler('help', help)
dispatcher.add_handler(Ping)
dispatcher.add_handler(Start)
dispatcher.add_handler(Get)
dispatcher.add_handler(Help)

updater.start_polling()
