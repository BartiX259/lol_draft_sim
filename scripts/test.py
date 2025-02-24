#!/bin/python3
import requests
import json

with open("key.txt", "r", encoding="utf-8") as file:
    key = file.readline().strip()

content = "Pedal board for acoustic guitar, used in worship at church, give me build of board and settings for individual effects"

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
    print(output)
except:
    print("nah")
    exit(1)
