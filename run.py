#!/bin/python3
import subprocess
import glob

champ_files = glob.glob("champions/*.champ")
command = ["./scripts/compile_champ.py"] + champ_files + ["-o", "champions/lua/"]
ret = subprocess.run(command).returncode
if ret != 0:
    exit(ret)
subprocess.run(["love", "."])
