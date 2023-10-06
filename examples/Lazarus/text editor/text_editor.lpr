program text_editor;

{$apptype gui}

uses webui;

procedure btnclose(e: PWebUIEvent);
begin
  webui_exit;
end;

var
  window: size_t;

begin
  // Create a new window
  window := webui_new_window;

  // Set the root folder for the UI
  webui_set_root_folder(window, 'ui');

  // Bind HTML elements with the specified ID to Free Pascal functions
  webui_bind(window, '__close-btn', @btnclose);

  // Show the window, preferably in a Chromium based browser
  if not webui_show_browser(window, 'index.html', WEBUI_ChromiumBased) then
    webui_show(window, 'index.html');

  // Wait until all windows get closed
  webui_wait;

  // Free all memory resources (Optional)
  webui_clean;
end.

