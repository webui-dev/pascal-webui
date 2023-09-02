program minimal;

{$mode objfpc}{$H+}

uses
  webui_static;

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
  webui_show(window, '<html><head><script src="/webui.js"></script></head><body><style>#main {width: 500; height: 500;}</style><h1 style="color: green;">this lesson to lear button event and links with pascal</h1><h3><br/><br/><button id="MyID">Hello</button></h3></body></html>');
  webui_wait;
end.

