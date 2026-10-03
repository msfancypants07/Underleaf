#!/usr/bin/env python3
"""Export the browser demo and landing page; templates live in builds/templates."""
from pathlib import Path
import os, shutil, subprocess, sys, zipfile
ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
GODOT = os.environ.get('GODOT', '/Applications/Godot.app/Contents/MacOS/Godot')
if len(sys.argv) > 1:
    with zipfile.ZipFile(sys.argv[1]) as archive:
        dest = ROOT / 'builds/templates'
        dest.mkdir(parents=True, exist_ok=True)
        for name in ['web_nothreads_debug.zip', 'web_nothreads_release.zip']:
            (dest/name).write_bytes(archive.read('templates/'+name))
output = ROOT / 'builds/web'
(output/'play').mkdir(parents=True, exist_ok=True)
subprocess.run([GODOT, '--headless', '--path', str(ROOT), '--editor', '--quit'], check=True)
subprocess.run([GODOT, '--headless', '--path', str(ROOT), '--export-release', 'Web', str(output/'play/index.html')], check=True)
shutil.copy2(ROOT/'site/index.html',output/'index.html')
shutil.copy2(ROOT/'docs/screenshots/tutorial.png',output/'tutorial.png')
shutil.copy2(ROOT/'THIRD_PARTY_NOTICES.md',output/'THIRD_PARTY_NOTICES.txt')
shutil.copytree(ROOT/'assets/fonts',output/'font-licenses',dirs_exist_ok=True,ignore=shutil.ignore_patterns('*.ttf','*.import'))
(output/'.nojekyll').touch()
print('Browser demo:',output)
