#!/bin/python3
from urllib.request import urlopen
from bs4 import BeautifulSoup
import difflib
import requests
import json
import argparse
import os
import glob

with open("key.txt", "r", encoding="utf-8") as file:
    key = file.readline().strip()

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

parser = argparse.ArgumentParser(description="Use AI to generate stats for a .champ file")
parser.add_argument("champ_files", nargs="+", help="The .champ files")
parser.add_argument("-a", "--auto-write", action="store_true", help="Write the file automatically instead of showing actions")
args = parser.parse_args()

# Process each argument
files = []
for pattern in args.champ_files:
    if os.path.exists(pattern):  # If it's a real file, keep it
        files.append(pattern)
    else:  # Otherwise, assume it's a pattern and expand it
        files.extend(glob.glob(pattern))

for file_path in files:
    name = os.path.splitext(os.path.basename(file_path))[0]
    name = "_".join(word.capitalize() for word in name.split("_"))
    replacements = { "Jarvan_Iv": "Jarvan_IV", "Cho_Gath": "Cho'Gath", "Kai_Sa": "Kai'Sa", "Vel_Koz": "Vel'Koz"}
    if name in replacements:
        name = replacements[name]
    print(name)

    with open(file_path, "r", encoding="utf-8") as file:
        champ_file = file.read().strip()

    print("Reading the wiki")
    wiki = text_from_url(f"https://leagueoflegends.fandom.com/wiki/{name}/LoL")
    # print("Reading build site")
    # build = text_from_url(f"https://www.metasrc.com/lol/build/{name}")

    content = """I'm making a League of Legends teamfight simulator and need accurate in-game numbers. I will send a champion file, where the stats need to be updated and the champion's wiki page. Assume the champion is level 13, has maxed basic abilities, and has two points in their ultimate. Assume the champion has their boots of choice (assume they are free), and around 5000 gold worth of raw stats from this table:
    Champion Statistic	    Base Item	        Item Cost	    Stat Raised
    Attack damage	        Long Sword	        350	            10 AD
    Ability haste	        Glowing Mote	    250	            5 AH
    Ability power	        Amplifying Tome	    400	            20 AP
    Armor	                Cloth Armor	        300	            15 Armor
    Magic resistance	    Null-Magic Mantle	400	            20 MR
    Health	                Ruby Crystal	    400	            150 HP
    Attack speed	        Dagger	            250	            10% AS
    Heal and shield power	Forbidden Idol	    600	            8% HS Power

    Choose the stats that the champion would get from their normal items, for example enchanters prefer forbidden idols over amp tomes.
    Some champions have passives or passive abilities that essentially boost their stats or damage so account for those in this section.

    The simulator only supports simple damage calculations, so adjust for factors like crit chance and penetration by increasing the damage appropriately. If an ability has non-standard scalings like enemy max HP, do not ignore it, but don't assume the best case scenario (for example, max HP scaling – enemy isn't a tank, but something like a mage). When an ability has multiple parts or ticks, the simulator applies its damage for every part/tick separately, so in those cases don't calculate the total damage, only the part/tick damage.

    Ensure every relevant stat is updated, including obvious ones like movement speed (MS), projectile speed, hitbox size, and cooldowns changing with ability haste, as well as less obvious ones like ability tick rate, number of ticks, or duration. You can also assume that every stat in the file is a placeholder, so calculate the stats yourself without considering the ones already there. Don't waste time considering abilities that aren't in the file.

    Your response should contain a breakdown of your item and stat choices, the consideration of the champion's passives, the calculations of attributes, ability cooldowns, damages, non-standard scalings and non-obvious stats, and the updated champion file. Do not modify the file's structure, add new values or abilities – only update existing ones. Don't add any comments either."""
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
            action = "w" if args.auto_write else input("actions: [w - write, a - write and enable auto-write, c - print code, p - print whole response, d - print diff, q - quit]")
            if action == "a":
                action = "w"
                args.auto_write = True
            if action == "c":
                print("--- CODE ---")
                print(code)
                print("------------")
            elif action == "w":
                with open(file_path, "w") as file:
                    file.write(code)
                    print("Wrote to " + file_path)
                    break
            elif action == "d":
                diff = difflib.unified_diff(champ_file.split("\n"), code.split("\n"), fromfile=file_path, tofile="Code")
                for text in diff:
                    if text[:3] not in ('+++', '---', '@@ '):
                        print(text)
            elif action == "p":
                print(output) 
    except:
        print("nah")
        print(response.json())
        exit(1)
