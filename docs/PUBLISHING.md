# Publishing Underleaf

Repository: https://github.com/msfancypants07/Underleaf

- Browser demo: https://msfancypants07.github.io/Underleaf/
- Latest download: https://github.com/msfancypants07/Underleaf/releases/latest/download/Underleaf-macOS.zip
- Release notes: https://github.com/msfancypants07/Underleaf/releases/latest

## Website buttons

Link your existing personal website directly to those addresses. GitHub serves the
files, so your site does not need to store the app or change its link each release.
The browser demo is desktop-oriented; it is not a tested mobile interface.

## Source updates and browser demo

Commit changes and push `main`. The Publish browser demo workflow runs the tests,
exports the game using Godot 4.4.1, and deploys the landing page and demo to Pages.
The default branch and Pages build source must remain `main` and GitHub Actions.
Browser save data belongs to the page origin and browser profile. Changing hosts
will not automatically transfer it. Keep the `/Underleaf/play/` URL stable.

## Publish a new desktop download

1. Update `VERSION`, the version fields in `export_presets.cfg`, and `RELEASE_NOTES.md`.
2. Commit and push those changes to `main`.
3. Create and push a matching tag, for example:

   ```sh
   git tag v0.3.2
   git push origin v0.3.2
   ```

The Publish Mac download workflow tests, packages, ad-hoc signs, zips, and publishes
a release named for that tag. `VERSION` must match the tag without its leading `v`.
Each release uses exactly `Underleaf-macOS.zip`, so the latest-download link stays
stable. Wait for a successful workflow before announcing a release. An ordinary
source push updates the browser demo only, not the downloadable app.

No in-app updater is installed. Replacing the app preserves its external save;
maintain compatibility and migrations when changing the save schema.

## Local builds

```sh
python3 tools/build_macos.py
python3 tools/build_web.py /path/to/Godot_v4.4.1-stable_export_templates.tpz
python3 -m http.server 8000 --directory builds/web
```

`GODOT` can override the engine executable. Obtain matching templates from the
official godotengine/godot-builds 4.4.1-stable release. The web build uses a single
thread, bundled OFL fonts, and stream playback for synthetic audio. Serve over
HTTP locally and HTTPS publicly; opening the HTML as a file will not work.

## Distribution limits

The Mac launcher and bundled engine contain both arm64 and x86_64. Intel runtime
validation is still outstanding. The current app uses ad-hoc signing; Developer ID
signing and Apple notarization require the owner's Apple Developer credentials and
are not configured. Downloaded copies may be blocked by Gatekeeper. The browser
demo avoids that installation barrier.

Do not commit signing keys, credentials, local saves, build outputs, or `.godot/`.
No open-source license for original game content has been selected; public source
availability alone does not grant a software license. Third-party font and engine
licenses are preserved in the repository and distribution notices.
