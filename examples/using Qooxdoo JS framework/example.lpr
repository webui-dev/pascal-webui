program example;

uses
  webui, SysUtils;

var
  window: size_t;
  content: PChar;
  counter: Integer;

procedure EventHandler(e: PWebUIEvent);
begin
  writeln('Received callback: ', webui_get_string(e));
  inc(counter);
  webui_return_string(e, PChar('{"label1": "Message from Free Pascal", "label2": "' + IntToStr(counter) + '"}'));
end;

begin
  counter := 0;
  window := webui_new_window;
  webui_bind(window, 'Button1Click', @EventHandler);
  content := '<!DOCTYPE html><html><head><script src="/webui.js"></script></head><body><script>function loadData(){fetch("index.html").then(response=>response.text()).then(content=>{document.open("text/html");document.write(content);document.close();console.log(content);}).catch(error=>{console.error(error);});}window.onload=loadData;</script></body></html>';
  webui_show(window, content);
  webui_wait;
end.
