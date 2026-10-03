#!/usr/bin/env python3
"""Build a local standalone .app using the installed Godot 4.4.1 engine."""
from pathlib import Path
import os, plistlib, shutil, subprocess
ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
VERSION = (ROOT / 'VERSION').read_text().strip()
(ROOT / 'builds').mkdir(exist_ok=True)
(ROOT / 'builds/.gdignore').touch()
GODOT = os.environ.get('GODOT', '/Applications/Godot.app/Contents/MacOS/Godot')
def run(*args):
    subprocess.run(args, check=True)
run(GODOT, '--headless', '--path', str(ROOT), '--export-pack', 'macOS', 'builds/Underleaf.pck')
run(GODOT, '--headless', '--path', str(ROOT), '--script', 'tools/icon.gd')
app = ROOT / 'builds/Underleaf.app'
mac = app / 'Contents/MacOS'
res = app / 'Contents/Resources'
mac.mkdir(parents=True, exist_ok=True)
res.mkdir(parents=True, exist_ok=True)
shutil.copy2(GODOT, mac / 'Engine')
shutil.copy2(ROOT / 'builds/Underleaf.pck', res / 'Underleaf.pck')
run('clang', '-arch', 'arm64', '-arch', 'x86_64', '-mmacosx-version-min=12.0', '-Os', str(ROOT / 'tools/launcher.c'), '-o', str(mac / 'Underleaf'))
icons = ROOT / 'builds/Underleaf.iconset'
icons.mkdir(exist_ok=True)
for size in [16, 32, 128, 256, 512]:
    for scale in [1, 2]:
        name = f'icon_{size}x{size}' + ('@2x' if scale == 2 else '') + '.png'
        run('sips', '-z', str(size*scale), str(size*scale), str(ROOT/'builds/icon.png'), '--out', str(icons/name))
run('iconutil', '-c', 'icns', str(icons), '-o', str(res/'Underleaf.icns'))
info = {
    'CFBundleName': 'Underleaf', 'CFBundleDisplayName': 'Underleaf',
    'CFBundleIdentifier': 'garden.underleaf.game', 'CFBundleExecutable': 'Underleaf',
    'CFBundleIconFile': 'Underleaf.icns', 'CFBundlePackageType': 'APPL',
    'CFBundleShortVersionString': VERSION, 'CFBundleVersion': VERSION,
    'LSMinimumSystemVersion': '12.0', 'NSHighResolutionCapable': True,
    'NSHumanReadableCopyright': 'Underleaf original game content. Godot Engine is MIT licensed.',
}
with (app/'Contents/Info.plist').open('wb') as f:
    plistlib.dump(info, f)
shutil.copy2(ROOT/'THIRD_PARTY_NOTICES.md',res/'THIRD_PARTY_NOTICES.md')
(res/'font-licenses').mkdir(exist_ok=True)
for license_file in (ROOT/'assets/fonts').glob('*-OFL.txt'):
    shutil.copy2(license_file,res/'font-licenses'/license_file.name)
run('codesign', '--force', '--deep', '--sign', '-', str(app))
run('codesign', '--verify', '--deep', '--strict', str(app))
run('ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', str(app), str(ROOT/'builds/Underleaf-macOS.zip'))
print(f'Built and verified {app}')
