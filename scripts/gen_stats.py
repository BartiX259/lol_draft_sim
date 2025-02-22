#!/bin/python3
from urllib.request import urlopen
from bs4 import BeautifulSoup
import difflib
import requests
import json
import argparse
import os

parser = argparse.ArgumentParser(description="Use AI to generate stats for a .champ file")
parser.add_argument("champ_file", help="The .champ file")
args = parser.parse_args()

name = os.path.splitext(os.path.basename(args.champ_file))[0]

with open("key.txt", "r", encoding="utf-8") as file:
    key = file.readline().strip()
with open(args.champ_file, "r", encoding="utf-8") as file:
    champ_file = file.read().strip()

def text_from_url(url):
    html = urlopen(url).read()
    soup = BeautifulSoup(html, features="html.parser")

    # kill all script and style elements
    for script in soup(["script", "style"]):
        script.extract()    # rip it out

    # get text
    text = soup.get_text()

    # break into lines and remove leading and trailing space on each
    lines = (line.strip() for line in text.splitlines())
    # break multi-headlines into a line each
    chunks = (phrase.strip() for line in lines for phrase in line.split("  "))
    # drop blank lines
    text = '\n'.join(chunk for chunk in chunks if chunk)

    return text

print("Reading the wiki")
wiki = text_from_url(f"https://leagueoflegends.fandom.com/wiki/{name.capitalize()}/LoL")
# print("Reading build site")
# build = text_from_url(f"https://www.metasrc.com/lol/build/{name}")

content = "I'm making a League of Legends teamfight simulator and need accurate in-game numbers. I will send a champion file, where the stats may need to be updated. Assume the champion has two items, boots, is level 13, has maxed basic abilities, and has two points in their ultimate. The simulator only supports simple damage calculations, so adjust for factors like crit chance and penetration by increasing the damage appropriately. Maybe even account for an item's special ability by increasing the abilities' damage or the champion's attributes etc. Ensure every relevant stat is updated, including obvious ones like movement speed (ms), projectile speed, and hitbox size, as well as less obvious ones like ability tick rate, number of ticks or duration. Provide a breakdown of your item choices and all calculations involved and then replace all values in the provided champion file with the ones you calculated. Do not modify the file's structure or add new values—only update existing ones. Don't add any comments either."
content += "\n------\nChampion file:\n"
content += champ_file
content += "\n------\nWiki of champion:\n"
content += wiki
# content += "common builds for champion:"
# content += build

# model = "gemini-2.0-pro-exp-02-05"
model = "gemini-2.0-flash-thinking-exp-01-21"
print("Asking " + model)
response = requests.post(
  url="https://generativelanguage.googleapis.com/v1beta/models/" + model + ":generateContent?key=" + key,
  headers={
    "Content-Type": "application/json"
  },
  data = json.dumps({
    "contents": [{
        "parts": [{"text": content}]
    }]
})
)
try:
    output = response.json()['candidates'][0]['content']['parts'][0]['text']
    code = output.split("```", 1)[1].split("```", 1)[0].strip()
    print("--- CODE ---")
    print(code)
    print("------------")
    action = ""
    while action != "q":
        action = input("actions: [w - write, c - print code, p - print whole response, d - print diff, q - quit]")
        if action == "c":
            print("--- CODE ---")
            print(code)
            print("------------")
        elif action == "w":
            with open(args.champ_file, "w") as file:
                file.write(code)
                break
        elif action == "d":
            diff = difflib.unified_diff(champ_file.split("\n"), code.split("\n"), fromfile=args.champ_file, tofile="Code")
            for text in diff:
                if text[:3] not in ('+++', '---', '@@ '):
                    print(text)
        elif action == "p":
            print(output) 
except:
    print("nah")
    exit(1)
