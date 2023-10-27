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

![33rsCSUo5W](https://github.com/webui-dev/pascal-webui/assets/21068718/b24b6b7e-013e-418d-a965-8b4255dcd47d)

## x64 only
Note that WebUI is x64 only, its already set up in the Lazarus Project Information file. You may want to change target OS between `Win64`, `Linux` or `MacOS`/`Darwin`.
