program qxexample;

{$mode objfpc}{$H+}

uses
  webui, sysutils;

var
  window: size_t;
  content: PChar;
  counter: Integer;

procedure EventHandler(e: Pwebui_event_t);
begin
    writeln('Received callback: ', e^.data);
    inc(counter);
    webui_interface_set_response(e^.window, e^.event_number, PChar('{"label1": "Message from Free Pascal", "label2": "' + IntToStr(counter) + '"}'));
end;

begin
  counter := 0;
  window := webui_new_window;
  webui_bind(window, 'Button1Click', @EventHandler);
  content := '<!DOCTYPE html><html><head></head><body><script>function loadData(){fetch("index.html").then(response=>response.text()).then(content=>{document.open("text/html");document.write(content);document.close();console.log(content);}).catch(error=>{console.error(error);});}window.onload=loadData;</script></body></html>';
  webui_show(window, content);
  webui_wait;
end.