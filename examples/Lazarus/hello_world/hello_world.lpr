program hello_world;

uses webui;

procedure btn_greet(e: PWebUIEvent);
begin
  webui_run(e^.window, 'document.getElementById("message").innerText = "Hello from Pascal!";');
end;

procedure btn_close(e: PWebUIEvent);
begin
  webui_exit;
end;

var
  window: size_t;

begin
  window := webui_new_window;

  webui_bind(window, 'btn_greet', @btn_greet);
  webui_bind(window, 'btn_close', @btn_close);

  webui_set_size(window, 400, 300);
  webui_set_center(window);

  if not webui_show_browser(window, 'index.html', WEBUI_ChromiumBased) then
    webui_show(window, 'index.html');

  webui_wait;
  webui_clean;
end.
