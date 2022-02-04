import re
from random import choice
import requests
from bs4 import BeautifulSoup


class Hax:
    @staticmethod
    def get_ua(brower_name):
        useragent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"
        return useragent

    def check(self, url):
        headers = {
            "User-Agent": self.get_ua("Safari"),
            "Content-type": "application/json",
        }
        datas = requests.get(url, headers=headers).text
        return datas

    def get_server_info(self):
        html_text = self.check("https://hax.co.id/data-center")
        soup = BeautifulSoup(html_text, "html.parser")
        zone_tags = soup("h5", class_="card-title mb-4")
        sum_tags = soup("h1", class_="card-text")
        vps_dict = dict(map(lambda x, y: [x.text, y.text], zone_tags, sum_tags))
        return vps_dict

    def get_data_center(self):
        html_text = self.check("https://hax.co.id/create-vps")
        soup = BeautifulSoup(html_text, "html.parser")
        center_list = [x.text for x in soup("option", value=re.compile(r"^[A-Z]{2,}-"))]
        center_str = "\n".join(center_list)
        return center_list, center_str

    def main(self):
        vps_dict = self.get_server_info()
        vps_str = ""
        for k, v in vps_dict.items():
            vps_str += str(k) + "\t" + str(v) + "\n"
        srv_stat = f"[🛰Opened Server Statistics / 已开通的服务器数据]\n{vps_str}\n\n"
        center_list, center_str = self.get_data_center()
        data_center = (
            f"[🚩Currently available data centers / 当前可开通的数据中心]\n{center_str}\n\n"
        )
        eu_mid1 = (
            "[♨Special Focus / 特别关注]\nEU Middle Specs (KVM + SSD) are NOT available now.\t暂时没有库存。"
            if "EU Middle Specs" not in center_str
            else "CHECK https://hax.co.id/create-vps NOW!!! EU Middle Specs (KVM + SSD) are available now.\t有库存！"
        )
        msg = srv_stat + data_center + eu_mid1
        return msg

print(Hax().main())
