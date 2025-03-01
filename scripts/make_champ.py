#!/bin/python3
from urllib.request import urlopen
from bs4 import BeautifulSoup
import difflib
import requests
import json
import argparse
import os
import glob


parser = argparse.ArgumentParser(description="Use AI to make a .champ file")
parser.add_argument("name", help="The champion's name")
parser.add_argument("abilities", nargs="+", help="The champion's abilities")
parser.add_argument("-e", "--extra", help="Extra advice for the model")
# parser.add_argument("-a", "--auto-write", action="store_true", help="Write the file automatically instead of showing actions")
args = parser.parse_args()

with open("key.txt", "r", encoding="utf-8") as file:
    key = file.readline().strip()

# Process each argument

content = f"""I am sending some code written with a custom language for designing league of legends champions. Based on the examples, can you make {args.name}? The abilities you should make are {", ".join(args.abilities[:-1])} and {args.abilities[-1]}."""
if args.extra:
    content += " " + args.extra
content += "\nExample code:"

# Match files using a glob pattern (e.g., all .txt files in a directory)
files = glob.glob("champions/*.champ")

# Read and combine contents of all matched files
content += "\n".join(open(file, "r", encoding="utf-8").read() for file in files)
# print(content)
# exit(1)

model = "gemini-2.0-pro-exp-02-05"
# model = "gemini-2.0-flash-thinking-exp-01-21"
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
        action = input("actions: [w - write, c - print code, p - print whole response, q - quit]")
        if action == "c":
            print("--- CODE ---")
            print(code)
            print("------------")
        elif action == "w":
            file_path = "champions/" + args.name + ".champ"
            with open(file_path, "w") as file:
                file.write(code)
                print("Wrote to " + file_path)
                break
        elif action == "p":
            print(output) 
except:
    print("nah")
    print(response.json())
    exit(1)
