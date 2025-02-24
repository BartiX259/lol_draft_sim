#!/bin/python3
import re
import sys

util_imports = {"vec2", "distances"}
lua_keywords = {"and", "or", "not", "if", "elseif", "else", "then", "end", "for", "while", "do", "function", "nil", "local", "true", "false"}

def custom_excepthook(exc_type, exc_value, exc_traceback):
    if issubclass(exc_type, CompilerError):
        print(exc_value)  # Only prints the error message, no traceback
    else:
        sys.__excepthook__(exc_type, exc_value, exc_traceback)  # Default behavior for other exceptions

sys.excepthook = custom_excepthook
cur_file = ""

class CompilerError(Exception):
    def __init__(self, message, line_number):
        self.message = message
        self.line_number = line_number
        self.file_name = cur_file
        super().__init__(self.__str__())  # Ensures the built-in message is overridden

    def __str__(self) -> str:
        return (f"\033[1;31merror:\033[0m \033[1m{self.message}\033[0m\n"
                f"   \033[34m-->\033[0m {self.file_name} line {self.line_number}")

import re

def tokenize_file(file_path):
    all_tokens = []

    # Regular expression to handle:
    # - Words (alphanumeric and _)
    # - Symbols (including # as a separate token)
    # - Multi-character symbols like >=, <=, etc.
    # - Percentages and numbers together (e.g., 75%)
    pattern = r"[\w.]+(?:%?)|[^\w\s#]+|#|\d+[%]?"

    with open(file_path, "r", encoding="utf-8") as file:
        for line in file:
            # Remove comments using regex (everything after "--")
            line = re.sub(r"--.*", "", line).strip()

            if not line:
                all_tokens.append([])
                continue  # Skip empty lines

            # Use regex to split line into tokens
            line_tokens = re.findall(pattern, line)
            all_tokens.append(line_tokens)  # Add the token list for this line

    return all_tokens

def pseudo_tokens(line_tokens):
    res = []
    tok_count = len(line_tokens)
    i = 0
    while i < tok_count:
        token = line_tokens[i]
        if token.endswith(":"):
            res.append(token + line_tokens[i+1])
            i += 1
        else:
            res.append(token)
        i += 1
    return res

def assert_tok_count(n, tok_count, line_nr):
    if tok_count < n:
        raise CompilerError("Too few tokens in this line", line_nr)
    if tok_count > n:
        raise CompilerError("Too many tokens in this line", line_nr)



def build_champion_table(tokens):
    champion = {
        "attributes": {},
        "abilities": {},
        "behavior": [],
        "imports": {"util": {"champion"}, "projectiles": set(), "abilities": set(), "effects": set()},
        "line_nrs": {}
    }
    current_block = "global"
    current_ability = None
    current_subsection = None
    line_nr = 0

    for line_tokens in tokens:
        line_nr += 1
        # print(line_nr)
        tok_count = len(line_tokens)
        if tok_count == 0: # Skip empty lines
            continue
        key = line_tokens[0]  # The first token is always the key
        is_colon = tok_count == 2 and line_tokens[1] == ":"
        if key == "champion" and current_block == "global":
            champion["name"] = line_tokens[1]
        elif key == "sprite" and current_block == "global":
            champion["sprite"] = line_tokens[1]
        elif key == "attributes" and is_colon:
            current_block = "attributes"
        elif key == "behavior" and is_colon:
            current_block = "behavior"
            champion["line_nrs"]["behavior"] = line_nr
        elif key == "abilities" and is_colon:
            current_block = "abilities"
            current_ability = ":global"
            champion["abilities"][current_ability] = {}
            champion["line_nrs"][current_ability] = {}
        elif current_block == "attributes":
            # Handle attributes like health, armor, etc.
            if key not in ["health", "armor", "mr", "ms"]:
                raise CompilerError("Invalid attribute '" + key + "'", line_nr)
            try:
                value = line_tokens[1]
                float(value)
            except:
                raise CompilerError("Expected number, for example: " + key + " 100", line_nr)
            champion["attributes"][key] = value
        elif current_block == "behavior":
            # Handle pseudo-code in behavior
            champion["behavior"].append(pseudo_tokens(line_tokens))
        elif current_block == "abilities":
            if is_colon:
                if key in ["cast", "use", "hit"]:
                    if current_ability == ":global":
                        raise CompilerError(key + " not in ability block!", line_nr)
                    current_subsection = key
                    champion["abilities"][current_ability][current_subsection] = []
                    champion["line_nrs"][current_ability][current_subsection] = line_nr
                else:
                    # Switch to a new specific ability
                    if key in ["behavior"]: # Forbidden names
                        raise CompilerError("'" + key + "' is reserved", line_nr)
                    current_ability = key
                    current_subsection = None
                    champion["abilities"][current_ability] = {}
                    champion["line_nrs"][current_ability] = {}
            else:
                if current_subsection:
                    champion["abilities"][current_ability][current_subsection].append(pseudo_tokens(line_tokens))
                else:
                    champion["line_nrs"][current_ability][key] = line_nr
                    if key == "cast":
                        if tok_count < 2:
                            raise CompilerError("Too few tokens in this line", line_nr)
                        if line_tokens[1] in ["after", "with"]:
                            if tok_count < 3:
                                raise CompilerError("Expected cast " + line_tokens[1] + " <ability_name>", line_nr)
                            if tok_count > 3:
                                raise CompilerError("Too many tokens in this line", line_nr)
                            champion["abilities"][current_ability][key] = (line_tokens[1], line_tokens[2])
                        elif line_tokens[1] == "if":
                            assert_tok_count(4, tok_count, line_nr)
                            champion["abilities"][current_ability][":cast_join"] = line_tokens[2]
                            if line_tokens[3] != ":":
                                raise CompilerError("Expected ':'", line_nr)
                            current_subsection = key
                            champion["abilities"][current_ability][current_subsection] = []
                            champion["line_nrs"][current_ability][current_subsection] = line_nr
                        elif tok_count > 2 and line_tokens[2] == "if":
                            assert_tok_count(4, tok_count, line_nr)
                            champion["abilities"][current_ability][key] = line_tokens[1]
                            champion["abilities"][current_ability][":cast_join"] = line_tokens[3]
                        else:
                            assert_tok_count(2, tok_count, line_nr)
                            champion["abilities"][current_ability][key] = line_tokens[1]
                    elif key == "color":
                        champion["abilities"][current_ability][key] = "{ "
                        for token in line_tokens[1:]:
                            champion["abilities"][current_ability][key] += token
                        champion["abilities"][current_ability][key] += " }"
                    elif key == "stats":
                        assert_tok_count(2, tok_count, line_nr)
                        if line_tokens[1] not in champion["abilities"]:
                            raise CompilerError(f"Ability '{line_tokens[1]}' not defined", line_nr)
                        for key, value in champion["abilities"][line_tokens[1]].items():
                            if key not in ["cast", "use", "hit"]:
                                champion["abilities"][current_ability][key] = value
                    else:
                        assert_tok_count(2, tok_count, line_nr)
                        if line_tokens[1] in champion["abilities"]:
                            champion["abilities"][current_ability][key] = champion["abilities"][line_tokens[1]][key]
                        else:
                            champion["abilities"][current_ability][key] = line_tokens[1]
        else:
            raise CompilerError("Invalid key or syntax error", line_nr)

    # Use abilities global table
    for glob in champion["abilities"][":global"]:
        for ability in champion["abilities"]:
            if ability == ":global":
                continue
            if not glob in champion["abilities"][ability]:
                champion["abilities"][ability][glob] = champion["abilities"][":global"][glob]
    del champion["abilities"][":global"]
    # Reserve tables
    for ability, data in champion["abilities"].items():
        for res in ["local", "global"]:
            if res in data:
                raise CompilerError("'" + res + "' is reserved", champion["line_nrs"][ability][res])
            data[res] = []

    return champion

def try_replace(word, match, replacement):
    if word == match:
        # print(word + " repl " + replacement)
        return replacement
    if word.startswith(match + "."):
        # print(word + " startswith " + match + ".")
        return replacement + "." + word.split(".", 1)[1]
    return None

def alias(word, champion, info):
    if word in lua_keywords:
        return word
    if word in info["local"]:
        return word
    for match in info["global"]:
        rep = try_replace(word, match, "self." + word.split(".", 1)[0])
        if rep != None:
            return rep
    if word in info and isinstance(info[word], str):
        return info[word]
    for ability, data in champion["abilities"].items():
        if word.startswith(ability + "."):
            acc = word.split(".")[1]
            if acc in data:
                return data[acc]
            return "champ.abilities." + word
    replacements = {
        "self": "champ",
        "health%": "champ.health / champ.max_health"
    }
    domains = {
        "champ": ["pos", "range"],
        "math": ["min", "max", "clamp"],
        "context": ["closest_enemy", "closest_ally", "closest_dist", "allies", "enemies"],
        "distances": ["in_range", "in_range_list", "find_clump"]
    }
    for match, replacement in replacements.items():
        rep = try_replace(word, match, replacement)
        if rep != None:
            return rep
    for domain, matches in domains.items():
        for match in matches:
            rep = try_replace(word, match, domain + "." + word.split(".", 1)[0])
            if rep != None:
                return rep
    return word

def default_args(func, info):
    match func:
        case "in_range" | "in_range_list":
            if "range" in info:
                return "distances." + func + "(champ, context.enemies, " + info["range"] + ")"
        case "find_clump":
            if "range" in info and "clump_range" in info:
                return "distances.find_clump(champ, context.enemies, " + info["range"] + ", " + info["clump_range"] + ")"
    return None

def generate_pseudo_code(stmts, info, champion, block, line_nr):
    res = ""
    close_after_end = [] 
    for stmt in stmts:
        tok_count = len(stmt)
        line = ""
        i = 0
        unclosed = []
        line_nr += 1
        while i < tok_count:
            token = stmt[i]
            defaults = default_args(token, info)
            if defaults != None:
                line += defaults
                line += " "
                i += 1
                continue
            if token in ["if", "for", "while", "function"]:
                close_after_end.append("")
            elif i == 0 and token.isidentifier() and i + 1 < tok_count and stmt[i+1] == "=" and alias(token, champion, info) == token and token not in info["local"]:
                info["global"].append(token)
            match token:
                case "missile":
                    champion["imports"]["projectiles"].add("missile")
                    keys = ["dir", "size", "speed", "color", "colliders", "range", "stop_on_hit", "from", "to", "hit_cols"]
                    missile = { "dir": "cast.dir", "colliders": "context.enemies",}
                    for key in keys:
                        if key in info:
                            missile[key] = alias(info[key], champion, info)
                        elif key in info["local"]:
                            missile[key] = key
                        elif key in info["global"]:
                            missile[key] = "self." + key
                    i += 1
                    while i < tok_count:
                        key = stmt[i]
                        if key in keys:
                            missile[key] = alias(stmt[i+1], champion, info)
                        else:
                            raise CompilerError("Unexpected missile argument '" + token + "'", line_nr)
                        i += 2
                    for nec in ["size", "color", "speed"]:
                        if nec not in missile:
                            raise CompilerError("Couldn't find '" + nec + "' for missile constructor", line_nr)
                    line += "missile.new(self, { "
                    for key, value in missile.items():
                        line += key + " = " + value + ",\n"
                    line += "})"
                case "aoe":
                    champion["imports"]["projectiles"].add("aoe")
                    keys = ["size", "color", "colliders", "deploy_time", "persist_time", "at", "hit_cols", "follow", "hard_follow"]
                    aoe = { "colliders": "context.enemies"}
                    on = None
                    for key in keys:
                        if key in info:
                            aoe[key] = alias(info[key], champion, info)
                        elif key in info["local"]:
                            aoe[key] = key
                        elif key in info["global"]:
                            aoe[key] = "self." + key
                    i += 1
                    while i < tok_count:
                        key = stmt[i]
                        if key in keys:
                            aoe[key] = alias(stmt[i+1], champion, info)
                        elif key == "on":
                            if stmt[i+1] in ["finish", "impact"]:
                                on = stmt[i+1]
                                i += 1
                                if stmt[i+1] == "do":
                                    close_after_end.append(")")
                                    i += 1
                                else:
                                    unclosed.append("end)")
                            else:
                                raise CompilerError("Expected 'on finish' or 'on impact'", line_nr)
                        else:
                            raise CompilerError("Unexpected aoe argument '" + token + "'", line_nr)
                        i += 2
                    for nec in ["size", "color"]:
                        if nec not in aoe:
                            raise CompilerError("Couldn't find '" + nec + "' for aoe constructor", line_nr)
                    line += "aoe:new(self, { "
                    for key, value in aoe.items():
                        line += key + " = " + value + ",\n"
                    line += "})"
                    if on:
                        line += f":on_{on}(function()"
                case "effect":
                    i += 1
                    token = stmt[i]
                    if token == "on":
                        line += alias(stmt[i+1], champion, info)
                        i += 2
                        token = stmt[i]
                    elif block == "hit":
                        line += "target"
                    else:
                        line += "cast.target"
                    champion["imports"]["effects"].add(token)
                    line += f":effect({token}.new("
                    effect = {}
                    i += 1
                    while i < tok_count:
                        token = stmt[i]
                        if token == "to":
                            effect["target"] = alias(stmt[i+1], champion, info)
                            i += 1
                        elif token == "speed":
                            effect["speed"] = float(alias(stmt[i+1], champion, info))
                            i += 1
                        elif token == "duration":
                            effect["duration"] = float(alias(stmt[i+1], champion, info))
                            i += 1
                        elif token == "amount":
                            effect["amount"] = float(alias(stmt[i+1], champion, info))
                            i += 1
                        elif re.match(r"^-?\d+(?:\.\d+)?s$", token):
                            effect["duration"] = float(token[:-1])
                        elif re.match(r"^-?\d+(?:\.\d+)?%$", token):
                            effect["amount"] = float(token[:-1]) / 100
                        elif re.match(r"^-?\d+(?:\.\d+)?$", alias(token, champion, info)):
                            effect["amount"] = float(alias(token, champion, info))
                        elif token == "on":
                            break
                        else:
                            raise CompilerError("Unexpected effect argument '" + token + "'", line_nr)
                        i += 1
                    for key in ["duration", "amount", "speed", "target"]:
                        if key in effect:
                            line += str(effect[key]) + ", "
                    line = line[:-2]
                    line += ")"
                    if i < tok_count and stmt[i] == "on":
                        if stmt[i+1] == "finish":
                            i += 1
                            line += ":on_finish(function()"
                            if stmt[i+1] == "do":
                                close_after_end.append("))")
                                i += 1
                            else:
                                unclosed.append("end))")
                        else:
                            raise CompilerError("Expected 'on finish'", line_nr)
                    else:
                        line += ")"
                case "spawn":
                    line += "context.spawn("
                    unclosed.append(")")
                case "delay":
                    line += "context.delay(" + alias(stmt[i+1], champion, info) + ", function()"
                    if stmt[i+2] == "do":
                        close_after_end.append(")")
                        i += 1
                    else:
                        unclosed.append("end)")
                    i += 1
                case "damage":
                    if i > 0:
                        line += alias(token, champion, info)
                    else:
                        champion["imports"]["util"].add("damage")
                        damage = {}
                        if "damage" in info:
                            damage["damage"] = info["damage"]
                        if block == "hit":
                            damage["target"] = "target"
                        else:
                            damage["target"] = "cast.target"
                        i += 1
                        while i < tok_count:
                            token = stmt[i]
                            try:
                                damage["damage"] = float(alias(token, champion, info))
                            except:
                                if token in ["magic", "physical", "true"]:
                                    damage["type"] = token.upper()
                                elif token == "to":
                                    damage["target"] = alias(stmt[i+1], champion, info)
                                    i += 1
                                else:
                                    raise CompilerError("Unexpected damage argument '" + token + "'", line_nr)
                            i += 1
                        if "target" not in damage:
                            raise CompilerError("Couldn't find 'target' for damage constructor", line_nr)
                        if "damage" not in damage:
                            raise CompilerError("Couldn't find 'damage' for damage constructor", line_nr)
                        if "type" not in damage:
                            raise CompilerError("Couldn't find damage type in constructor", line_nr)
                        line += f"damage:new({str(damage["damage"])}, damage.{damage["type"]}):deal(champ, {damage["target"]})"
                case "ready":
                    line += "ready." + stmt[i+1]
                    i += 1
                case "range":
                    if i > 0:
                        line += alias(token, champion, info)
                    else:
                        line += "champ.range = "
                        i += 1
                        while i < tok_count:
                            token = stmt[i]
                            if token in champion["abilities"]:
                                line += champion["abilities"][token]["range"]
                            else:
                                line += alias(token, champion, info)
                            i += 1
                case "movement":
                    if i > 0:
                        line += alias(token, champion, info)
                    else:
                        i += 1
                        champion["imports"]["util"].add("movement")
                        line += "champ:change_movement(movement." + stmt[i].upper() + ")"
                case "for":
                    line += "for "
                    i += 1
                    token = stmt[i]
                    while token not in ["=", "in"]:
                        if not "," in token and not token.lstrip().startswith("_"):
                            info["local"].append(token)
                        line += token
                        i += 1
                        token = stmt[i]
                    line += " " + token
                case "local":
                    i += 1
                    line += "local " + stmt[i]
                    info["local"].append(stmt[i])
                case "end":
                    line += "end"
                    if len(close_after_end) > 0:
                        line += close_after_end.pop()
                case _:
                    line += alias(token, champion, info)
            line += " "
            i += 1
        res += line[:-1]
        res += "\n"
        for i in reversed(unclosed):
            res += i + "\n"
    res = res[:-1]
    return res

def generate_lua_code(champion):
    lua_code = []

    # Champion Constructor
    lua_code.append(f"\nlocal {champion['name']} = {{}}")

    # Champion attributes (health, armor, etc.)
    lua_code.append(f"\n-- Constructor\nfunction {champion['name']}.new(x, y)")
    lua_code.append(f"  local champ = champion.new({{ x = x, y = y,")
    for key, value in champion['attributes'].items():
        lua_code.append(f"    {key} = {value},")
    lua_code.append(f"    sprite = '{champion['sprite']}',")
    lua_code.append(f"  }})")

    # Abilities declaration
    lua_code.append("\n  champ.abilities = {")
    
    for ability, ability_data in champion['abilities'].items():
        line = f"    {ability} = "
        if "cd" not in ability_data and ability_data["cast"] != "none" and not isinstance(ability_data["cast"], tuple) and ":cast_join" not in ability_data:
            raise CompilerError("Couldn't find 'cd' for cast", champion["line_nrs"][ability]["cast"])
        if isinstance(ability_data["cast"], str):
            champion["imports"]["abilities"].add(ability_data["cast"]) 
        if ":cast_join" in ability_data:
            ability_data["cd"] = 0
        match ability_data["cast"]:
            case "ranged":
                for nec in ["range"]:
                    if nec not in ability_data:
                        raise CompilerError("Couldn't find '" + nec + "' for cast ranged", champion["line_nrs"][ability]["cast"])
                line += f"ranged.new({ability_data['cd']}, {ability_data['range']})"
            case "splash":
                for nec in ["range", "size"]:
                    if nec not in ability_data:
                        raise CompilerError("Couldn't find '" + nec + "' for cast splash", champion["line_nrs"][ability]["cast"])
                line += f"splash.new({ability_data['cd']}, {ability_data['range']}, {ability_data['size']})"
            case "melee_aa":
                for nec in ["range", "damage"]:
                    if nec not in ability_data:
                        raise CompilerError("Couldn't find '" + nec + "' for cast melee_aa", champion["line_nrs"][ability]["cast"])
                line += f"melee_aa.new({ability_data['cd']}, {ability_data['range']}, {ability_data['damage']})"
            case "ranged_aa":
                for nec in ["range", "damage", "color"]:
                    if nec not in ability_data:
                        raise CompilerError("Couldn't find '" + nec + "' for cast ranged_aa", champion["line_nrs"][ability]["cast"])
                line += f"ranged_aa.new({ability_data['cd']}, {ability_data['range']}, {ability_data['damage']}, {ability_data['color']})"
            case "dash":
                for nec in ["dist"]:
                    if nec not in ability_data:
                        raise CompilerError("Couldn't find '" + nec + "' for cast dash", champion["line_nrs"][ability]["cast"])
                if "range" in ability_data:
                    line += f"dash.new({ability_data['cd']}, {ability_data['dist']}, {ability_data['range']})"
                else:
                    line += f"dash.new({ability_data['cd']}, {ability_data['dist']}, champ.range)"
            case "buff":
                for nec in ["range"]:
                    if nec not in ability_data:
                        raise CompilerError("Couldn't find '" + nec + "' for cast buff", champion["line_nrs"][ability]["cast"])
                line += f"buff.new({ability_data['cd']}, {ability_data['range']})"
            case "none":
                line += "none.new()"
            case (_, _):
                if "cd" in ability_data:
                    line += f"ability:new({ability_data['cd']})"
                    champion["imports"]["util"].add("ability") 
                else:
                    line += "none.new()"
                    champion["imports"]["abilities"].add("none") 
            case _:
                line += f"ability:new({ability_data['cd']})"
                champion["imports"]["util"].add("ability") 
        line += ','
        lua_code.append(line)
    
    lua_code.append("  }")
    for ability, ability_data in champion['abilities'].items():
        if ":cast_join" in ability_data:
            lua_code.append("champ.abilities." + ability + ":join(champ.abilities." + ability_data[":cast_join"] + ")")

    for ability, ability_data in champion['abilities'].items():
        if isinstance(ability_data["cast"], list): # Custom cast
            lua_code.append("function champ.abilities." + ability + ":cast(context)")
            lua_code.append(generate_pseudo_code(ability_data["cast"], ability_data, champion, "cast", champion["line_nrs"][ability]["cast"]))
            lua_code.append("end")
            lua_code.append("")
        if ability_data["cast"] not in ["melee_aa", "ranged_aa", "none"]: # Has use function
            if isinstance(ability_data["cast"], tuple): # Cast with another ability
                lua_code.append("function champ.abilities." + ability + ":" + ability_data["cast"][0] + "_" + ability_data["cast"][1] + "(context, cast)")
            else: # Custom use function
                lua_code.append("function champ.abilities." + ability + ":use(context, cast)")

            # Generate use function
            lua_code.append(generate_pseudo_code(ability_data["use"], ability_data, champion, "use", champion["line_nrs"][ability]["use"]))
            for other, other_data in champion["abilities"].items(): # Check if any abilities cast with this one
                if isinstance(other_data["cast"], tuple):
                    if other_data["cast"][1] != ability:
                        continue
                    if "cd" in other_data:
                        lua_code.append("if champ.abilities." + other + ".timer <= 0 then")
                        lua_code.append("champ.abilities." + other + ".timer = champ.abilities." + other + ".cd")
                    match other_data["cast"]:
                        case ("after", _):
                            lua_code.append("self.proj.after = function() champ.abilities." + other + ":after_" + ability + "(context, cast) end")
                        case ("with", _):
                            lua_code.append("champ.abilities." + other + ":with_" + ability + "(context, cast)")
                    if "cd" in other_data:
                        lua_code.append("end")
            lua_code.append("end")

        lua_code.append("")

        if "hit" in ability_data:
            lua_code.append("function champ.abilities." + ability + ":hit(target)")
            lua_code.append(generate_pseudo_code(ability_data["hit"], ability_data, champion, "hit", champion["line_nrs"][ability]["hit"]))
            lua_code.append("end")
            lua_code.append("")


    # Behavior Block
    lua_code.append("function champ.behaviour(ready, context)")
    lua_code.append(generate_pseudo_code(champion["behavior"], {"local": [], "global": []}, champion, "behavior", champion["line_nrs"]["behavior"]))
    lua_code.append("end")
    
    # Close the constructor
    lua_code.append(f"\n  return champ\nend")
    lua_code.append(f"\nreturn {champion['name']}")
    
    # Search for imports
    for line in lua_code:
        for i in util_imports:
            if i in line:
                champion["imports"]["util"].add(i)

    # Return the full Lua code
    imports = ""
    for key, values in champion["imports"].items():
        for value in values:
            imports += f"local {value} = require(\"{key}.{value}\")\n"
    return imports + '\n'.join(lua_code)

import argparse
import os

parser = argparse.ArgumentParser(description='Compile .champ files into .lua files')
parser.add_argument('champ_files', nargs='+', help='path to .champ file')
parser.add_argument('-o', '--output', help='path to output directory')
args = parser.parse_args()

for file_path in args.champ_files:
    if not os.path.isfile(file_path):
        print(file_path, "not a file")
        continue
    output_path = os.path.splitext(file_path)[0] + ".lua"
    if args.output != None:
        output_path = os.path.join(args.output, os.path.basename(output_path))
    os.makedirs(args.output, exist_ok=True)
    print(f"\033[1;34minfo:\033[0m  \033[1mcompiling {file_path} to {output_path}\033[0m")

    if output_path == file_path:
        print("Output path same as file path")
        exit(1)

    cur_file = file_path
    tokens = tokenize_file(file_path)

    # # Print tokenized output
    # for line_tokens in tokens:
    #     print(line_tokens)

    # Build the champion table
    champion_table = build_champion_table(tokens)
    # Print the resulting champion table
    # print(champion_table)

    # print(champion_table["abilities"]["q"])
    # Generate the Lua code
    lua_code = generate_lua_code(champion_table)

    # Print the resulting Lua code
    with open(output_path, "w") as file:
        file.write(lua_code)

print(f"\033[1;32msuccess:\033[0m \033[1mall compilations completed successfully!\033[0m")
