program example;

uses webui, SysUtils;

procedure js_log(window: size_t; message: string);
var
  s: string;
begin
  s := 'var div = document.createElement("div");';
  s += 'div.innerText = "'+message+'";';
  s += 'document.getElementById("log").append(div);';

  webui_run(window, pchar(s));
end;

procedure btn1click(e: PWebUIEvent);
begin
  writeln(e^.element, ' clicked');

  js_log(e^.window, 'Button clicked at '+DateTimeToStr(Now));
end;

procedure func(e: PWebUIEvent);
begin
  writeln(e^.element, ' called');
  writeln('arg 1 = ', webui_get_string_at(e, 0));
  writeln('arg 2 = ', webui_get_string_at(e, 1));

  js_log(e^.window, 'Pascal function called at '+DateTimeToStr(Now));
end;

var
  window: size_t;

begin
  window := webui_new_window;

  webui_bind(window, 'btn1', @btn1click);
  webui_bind(window, 'func', @func);

  webui_set_size(window, 500, 500);
  webui_set_position(window, 500, 250);

  webui_show(window, 'index.html');
  webui_wait;
end.

