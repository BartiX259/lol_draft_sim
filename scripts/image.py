import requests
import argparse
import glob
import os

parser = argparse.ArgumentParser(description="Download splash art for champions")
parser.add_argument("champ_files", nargs="+", help="Files containing the champions' names")
args = parser.parse_args()

# Process each argument
files = []
for pattern in args.champ_files:
    if os.path.exists(pattern):  # If it's a real file, keep it
        files.append(pattern)
    else:  # Otherwise, assume it's a pattern and expand it
        files.extend(glob.glob(pattern))

for file in files:
    name = os.path.basename(file).split(".")[0]
    replacements = {"wukong": "monkeyking" }
    url_name = name.replace("_", "")
    if url_name in replacements:
        url_name = replacements[url_name]
    print(url_name)
    image_url = f"https://raw.communitydragon.org/pbe/plugins/rcp-be-lol-game-data/global/default/assets/characters/{url_name}/skins/base/images/{url_name}_splash_tile_0.jpg"
    img_data = requests.get(image_url).content
    with open(f"assets/champions/{name}.jpg", 'wb') as handler:
        handler.write(img_data)