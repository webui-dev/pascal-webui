unit WebUI;

interface

// -- Consts --------------------------
const
  WEBUI_VERSION = '2.4.0';
  WEBUI_MAX_IDS = 512;
  webuilib = 'webui.dll';

type
// -- Enums ---------------------------
  webui_browsers = (
    AnyBrowser,        // 0. Default recommended web browser
    Chrome,            // 1. Google Chrome
    Firefox,           // 2. Mozilla Firefox
    Edge,              // 3. Microsoft Edge
    Safari,            // 4. Apple Safari
    Chromium,          // 5. The Chromium Project
    Opera,             // 6. Opera Browser
    Brave,             // 7. The Brave Browser
    Vivaldi,           // 8. The Vivaldi Browser
    Epic,              // 9. The Epic Browser
    Yandex             // 10. The Yandex Browser
  );

  webui_runtimes = (
    None,              // 0. Prevent WebUI from using any runtime for .js and .ts files
    Deno,              // 1. Use Deno runtime for .js and .ts files
    NodeJS             // 2. Use Nodejs runtime for .js files
  );

  webui_events = (
    WEBUI_EVENT_DISCONNECTED,               // 0. Window disconnection event
    WEBUI_EVENT_CONNECTED,                  // 1. Window connection event
    WEBUI_EVENT_MULTI_CONNECTION,           // 2. New window connection event
    WEBUI_EVENT_UNWANTED_CONNECTION,        // 3. New unwanted window connection event
    WEBUI_EVENT_MOUSE_CLICK,                // 4. Mouse click event
    WEBUI_EVENT_NAVIGATION,                 // 5. Window navigation event
    WEBUI_EVENT_CALLBACK                    // 6. Function call event
  );

// -- Structs -------------------------
  webui_event_t = record
    window: size_t; // The window object number
    event_type: size_t; // Event type
    element: PChar; // HTML element ID
    data: PChar; // JavaScript data
    size: Int64; // JavaScript data len
    event_number: size_t; // Internal WebUI
  end;

  Pwebui_event_t = ^webui_event_t;

  TWebuiEventProc = procedure(e: Pwebui_event_t);
  TWebuiInterfaceEventProc = procedure(window, event_type: size_t; element, data: PChar; data_size: Int64; event_number: size_t);

// -- Definitions ---------------------
// Create a new webui window object.
function webui_new_window: size_t; stdcall; external webuilib;
// Create a new webui window object.
procedure webui_new_window_id(window_number: size_t); stdcall; external webuilib;
// Get a free window ID that can be used with `webui_new_window_id()`
function webui_get_new_window_id: size_t; stdcall; external webuilib;
// Bind a specific html element click event with a function. Empty element means all events.
function webui_bind(window: size_t; const element: PChar; func: TWebuiEventProc): size_t; stdcall; external webuilib;
// Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed.
function webui_show(window: size_t; const content: PChar): Boolean; stdcall; external webuilib;
// Same as webui_show(). But with a specific web browser.
function webui_show_browser(window: size_t; const content: PChar; browser: size_t): Boolean; stdcall; external webuilib;
// Set the window in Kiosk mode (Full screen)
procedure webui_set_kiosk(window: size_t; status: Boolean); stdcall; external webuilib;
// Wait until all opened windows get closed.
procedure webui_wait; stdcall; external webuilib;
// Close a specific window only. The window object will still exist.
procedure webui_close(window: size_t); stdcall; external webuilib;
// Close a specific window and free all memory resources.
procedure webui_destroy(window: size_t); stdcall; external webuilib;
// Close all opened windows. webui_wait() will break.
procedure webui_exit; stdcall; external webuilib;
// Set the web-server root folder path.
function webui_set_root_folder(window: size_t; const path: PChar): Boolean; stdcall; external webuilib;
// Set the web-server root folder path for all windows. Should be used before `webui_show()`.
function webui_set_default_root_folder(const path: PChar): Boolean; stdcall; external external webuilib; 
// Set a custom handler to serve files
procedure webui_set_file_handler(window: size_t; handler: Pointer); stdcall; external webuilib;

// -- Other ---------------------------
// Check a specific window if it's still running
function webui_is_shown(window: size_t): Boolean; stdcall; external webuilib;
// Set the maximum time in seconds to wait for the browser to start
procedure webui_set_timeout(second: size_t); stdcall; external webuilib;
// Set the default embedded HTML favicon
procedure webui_set_icon(window: size_t; const icon, icon_type: PChar); stdcall; external webuilib;
// Allow the window URL to be re-used in normal web browsers
procedure webui_set_multi_access(window: size_t; status: Boolean); stdcall; external webuilib;
// Get process id (The web browser may create another process for the window)
function webui_get_child_process_id(window: size_t): size_t; stdcall; external webuilib;
function webui_get_parent_process_id(window: size_t): size_t; stdcall; external webuilib;

// -- JavaScript ----------------------
// Run JavaScript quickly with no waiting for the response.
procedure webui_run(window: size_t; const script: PChar); stdcall; external webuilib;
// Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).
function webui_script(window: size_t; const script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean; stdcall; external webuilib;
// Chose between Deno and Nodejs runtime for .js and .ts files.
procedure webui_set_runtime(window: size_t; runtime: size_t); stdcall; external webuilib;
// Parse argument as integer.
function webui_get_int(e: Pwebui_event_t): Int64; stdcall; external webuilib;
// Parse argument as string.
function webui_get_string(e: Pwebui_event_t): PChar; stdcall; external webuilib;
// Parse argument as boolean.
function webui_get_bool(e: Pwebui_event_t): Boolean; stdcall; external webuilib;
// Return the response to JavaScript as integer.
procedure webui_return_int(e: Pwebui_event_t; n: Int64); stdcall; external webuilib;
// Return the response to JavaScript as string.
procedure webui_return_string(e: Pwebui_event_t; const s: PChar); stdcall; external webuilib;
// Return the response to JavaScript as boolean.
procedure webui_return_bool(e: Pwebui_event_t; b: Boolean); stdcall; external webuilib;
// Base64 encoding. Use this to safely send text based data to the UI.
function webui_encode(const str: PChar): PChar; stdcall; external webuilib;
// Base64 decoding. Use this to safely decode received Base64 text from the UI.
function webui_decode(const str: PChar): PChar; stdcall; external webuilib;
// Safely free a buffer allocated by WebUI, for example when using webui_encode().
procedure webui_free(ptr: Pointer); stdcall; external webuilib;
// Safely allocate memory using the WebUI memory management system.
function webui_malloc(size: size_t): Pointer; stdcall; external webuilib;
// Safely send raw data to the UI.
procedure webui_send_raw(window: size_t; const func: PChar; raw: Pointer; size: size_t); stdcall; external webuilib;
// Run the window in hidden mode.
procedure webui_set_hide(window: size_t; status: Boolean); stdcall; external webuilib;
// Set the window size.
procedure webui_set_size(window: size_t; width, height: UInt32); stdcall; external webuilib;
// Set the window position.
procedure webui_set_position(window: size_t; x, y: UInt32); stdcall; external webuilib;

// -- Interface -----------------------
// Bind a specific html element click event with a function. Empty element means all events.
function webui_interface_bind(window: size_t; const element: PChar; func: TWebuiInterfaceEventProc): size_t; stdcall; external webuilib;
// When using `webui_interface_bind()` you may need this function to easily set your callback response.
procedure webui_interface_set_response(window, event_number: size_t; const response: PChar); stdcall; external webuilib;
// Check if the app is still running or not.
function webui_interface_is_app_running: Boolean; stdcall; external webuilib;
// Get window unique ID
function webui_interface_get_window_id(window: size_t): size_t; stdcall; external webuilib;
// Get a unique ID. Same ID as `webui_bind()`. Return > 0 if bind exists.
function webui_interface_get_bind_id(window: size_t; const element: PChar): size_t; stdcall; external webuilib;


implementation

end.
