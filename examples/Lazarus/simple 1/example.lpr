program example;

uses webui, SysUtils;

procedure btn1click(e: Pwebui_event_t);
var
  s: string;
begin
  writeln(e^.element, ' clicked');

  s := 'var div = document.createElement("div");';
  s += 'div.innerText = "Button clicked at '+DateTimeToStr(Now)+'";';
  s += 'document.getElementById("log").append(div);';

  webui_run(e^.window, pchar(s));
end;

var
  window: size_t;

begin
  window := webui_new_window;

  webui_bind(window, 'btn1', @btn1click);

  webui_set_size(window, 500, 500);
  webui_set_position(window, 500, 250);

  webui_show(window, 'index.html');
  webui_wait;
end.

