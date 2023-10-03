<div align="center">
  
<img src="https://raw.githubusercontent.com/webui-dev/webui-logo/main/webui_240.png" height="200">

# WebUI Pascal v2.4.0

[![Nightly Build](https://img.shields.io/badge/webui-dev%2Fwebui?style=for-the-badge&label=Nightly%20Build&labelColor=414868&logoColor=C0CAF5)](https://github.com/webui-dev/webui/releases/tag/nightly)
[![Last commit)](https://img.shields.io/github/last-commit/webui-dev/pascal-webui/main?style=for-the-badge&labelColor=414868&logoColor=C0CAF5)](https://github.com/webui-dev/pascal-webui/commits/main)
[![Issues](https://img.shields.io/github/issues/webui-dev/pascal-webui?style=for-the-badge&labelColor=414868&logoColor=C0CAF5)](https://github.com/webui-dev/pascal-webui/issues)
[![Website](https://img.shields.io/website?label=webui.me&style=for-the-badge&url=https://google.com&labelColor=414868&logoColor=C0CAF5)](https://webui.me/)
[![License](https://img.shields.io/github/license/webui-dev/pascal-webui?style=for-the-badge&label=License&labelColor=414868&logoColor=C0CAF5)](https://github.com/webui-dev/pascal-webui/blob/main/LICENSE)

WebUI is not a web-server solution or a framework, but it allows you to use any web browser as a GUI, with Pascal in the backend and HTML5 in the frontend. All in a lightweight portable lib.

<div align="center">

![WebUI](https://github.com/webui-dev/pascal-webui/assets/21068718/f88cc1e0-42a3-4422-bf9a-beeff17cc5d6)

</div>

</div>

## Features

- Fully Independent (*No need for any third-party runtimes*)
- Lightweight (~250 KB for minimal example, ~350 KB for basic app (no LCL) - including WebUI lib) & Small memory footprint
- Fast binary communication protocol between WebUI and the browser (*Instead of JSON*)
- Multi-platform & Multi-Browser
- Using private profile for safety
- Original library written in Pure C

## Minimal Example

```pas
program minimal;

{$mode objfpc}{$H+}

uses
  webui;

var
  window: size_t;

begin
  window := webui_new_window;

  webui_show(window, '<html>Hello World<script src="/webui.js"></script></html>');
  webui_wait;
end.
```

[More examples](https://github.com/webui-dev/pascal-webui/tree/main/examples)

## Text editor

This [text editor](https://github.com/webui-dev/pascal-webui/tree/main/examples/Lazarus/text%20editor) is a lightweight and portable example written in Free Pascal and JavaScript using WebUI as the GUI.

![Screenshot](https://github.com/webui-dev/pascal-webui/assets/21068718/685a483b-0230-4365-8378-f7808ba0d55c)

## Documentation

[Online documentation](https://webui.me/docs/#/c_api)

## Runtime Dependencies Comparison

|  | WebView | Qt | WebUI |
| ------ | ------ | ------ | ------ |
| Runtime Dependencies on Windows | *WebView2* | *QtCore, QtGui, QtWidgets* | ***A Web Browser*** |
| Runtime Dependencies on Linux | *GTK3, WebKitGTK* | *QtCore, QtGui, QtWidgets* | ***A Web Browser*** |
| Runtime Dependencies on macOS | *Cocoa, WebKit* | *QtCore, QtGui, QtWidgets* | ***A Web Browser*** |

## Supported Web Browsers

| Browser | Windows | macOS | Linux |
| ------ | ------ | ------ | ------ |
| Mozilla Firefox | ✔️ | ✔️ | ✔️ |
| Google Chrome | ✔️ | ✔️ | ✔️ |
| Microsoft Edge | ✔️ | ✔️ | ✔️ |
| Chromium | ✔️ | ✔️ | ✔️ |
| Yandex | ✔️ | ✔️ | ✔️ |
| Brave | ✔️ | ✔️ | ✔️ |
| Vivaldi | ✔️ | ✔️ | ✔️ |
| Epic | ✔️ | ✔️ | *not available* |
| Apple Safari | *not available* | *coming soon* | *not available* |
| Opera | *coming soon* | *coming soon* | *coming soon* |

## UI & The Web Technologies

[Borislav Stanimirov](https://ibob.bg/) discusses using HTML5 in the web browser as GUI at the [C++ Conference 2019 (*YouTube*)](https://www.youtube.com/watch?v=bbbcZd4cuxg).

<div align="center">

![CppCon](https://github.com/webui-dev/pascal-webui/assets/21068718/dd5f33ef-1342-407e-8a06-af6287d8e6c6)

</div>

Web application UI design is not just about how a product looks but how it works. Using web technologies in your UI makes your product modern and professional, And a well-designed web application will help you make a solid first impression on potential customers. Great web application design also assists you in nurturing leads and increasing conversions. In addition, it makes navigating and using your web app easier for your users.

### Why Use Web Browsers?

Today's web browsers have everything a modern UI needs. Web browsers are very sophisticated and optimized. Therefore, using it as a GUI will be an excellent choice. While old legacy GUI lib is complex and outdated, a WebView-based app is still an option. However, a WebView needs a huge SDK to build and many dependencies to run, and it can only provide some features like a real web browser. That is why WebUI uses real web browsers to give you full features of comprehensive web technologies while keeping your software lightweight and portable.

### How Does it Work?

![diagram](https://github.com/webui-dev/pascal-webui/assets/21068718/671299d2-05da-4ec9-b1af-28f3d915100c)

Think of WebUI like a WebView controller, but instead of embedding the WebView controller in your program, which makes the final program big in size, and non-portable as it needs the WebView runtimes. Instead, by using WebUI, you use a tiny static/dynamic library to run any installed web browser and use it as GUI, which makes your program small, fast, and portable. **All it needs is a web browser**.

## License

Licensed under the MIT License.

### Stargazers

[![Stargazers repo roster for @webui-dev/pascal-webui](https://reporoster.com/stars/webui-dev/pascal-webui)](https://github.com/webui-dev/pascal-webui/stargazers)
