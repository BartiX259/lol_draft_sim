#!/bin/python3
import subprocess
import glob

champ_files = glob.glob("champions/*.champ")
command = ["./scripts/compile_champ.py"] + champ_files + ["-o", "champions/lua/"]
subprocess.run(command)
subprocess.run(["love", "."])
