program minimal;

{$mode objfpc}{$H+}

uses
  webui;

var
  window: size_t;

procedure EventHandler(e: Pwebui_event_t);
begin
    writeln('Received callback: ', webui_events(e^.event_type));
end;

procedure MyIDEventHandler(e: Pwebui_event_t);
begin
    writeln('Received callback: ', 'Hello button pressed!');
end;

begin
  window := webui_new_window;
  webui_bind(window, '', @EventHandler);
  webui_bind(window, 'MyID', @MyIDEventHandler);
  webui_show(window, '1.html');
  webui_wait;
end.

