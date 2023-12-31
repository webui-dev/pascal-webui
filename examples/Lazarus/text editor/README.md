## Text editor

### Windows

1. [Download nightly build of WebUI library](https://github.com/webui-dev/webui/releases/tag/nightly) and put it next to the `text_editor.lpi` (`.dll` file needed)
2. Open the `text_editor.lpi` file in Lazarus
3. Compile, done!

![Screenshot](https://github.com/webui-dev/pascal-webui/assets/21068718/685a483b-0230-4365-8378-f7808ba0d55c)

### Linux
1. [Download nightly build of WebUI library](https://github.com/webui-dev/webui/releases/tag/nightly) and put it next to the `text_editor.lpi` (`.a` file needed)
2. Open the `text_editor.lpi` file in Lazarus
3. Change target to `Linux` in Project Settings (default is `Win64`)
4. Compile, done!

![Z7yjV50ybe](https://github.com/webui-dev/pascal-webui/assets/21068718/3252cc28-f55a-4ace-a502-0f0a57468ff5)

## x64 only
Note that WebUI is x64 only, its already set up in the Lazarus Project Information file. You may want to change target OS between `Win64`, `Linux` or `MacOS`/`Darwin`.
