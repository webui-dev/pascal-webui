unit WebUI_static;

interface

{$linklib libs/libwebui-2-static-x64.a}
{$linklib libs/libgcc.a}
{$linklib libs/libkernel32.a}
{$linklib libs/libadvapi32.a}
{$linklib libs/libuser32.a}
{$linklib libs/libmingwex.a}
{$linklib libs/libucrt.a}
{$linklib libs/libmincore.a}
{$linklib libs/libmsvcr120.a}

// -- Consts --------------------------
const
  WEBUI_VERSION = '2.4.0';
  WEBUI_MAX_IDS = 512;

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
    window: SizeInt; // The window object number
    event_type: SizeInt; // Event type
    element: PChar; // HTML element ID
    data: PChar; // JavaScript data
    size: Int64; // JavaScript data len
    event_number: SizeInt; // Internal WebUI
  end;

  Pwebui_event_t = ^webui_event_t;

  TWebuiEventProc = procedure(e: Pwebui_event_t);
  TWebuiInterfaceEventProc = procedure(window, event_type: SizeInt; element, data: PChar; data_size: Int64; event_number: SizeInt);

// -- Definitions ---------------------
// Create a new webui window object.
function webui_new_window: SizeInt; stdcall; external;
// Create a new webui window object.
procedure webui_new_window_id(window_number: SizeInt); stdcall; external;
// Get a free window ID that can be used with `webui_new_window_id()`
function webui_get_new_window_id: SizeInt; stdcall; external;
// Bind a specific html element click event with a function. Empty element means all events.
function webui_bind(window: SizeInt; const element: PChar; func: TWebuiEventProc): SizeInt; stdcall; external;
// Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed.
function webui_show(window: SizeInt; const content: PChar): Boolean; stdcall; external;
// Same as webui_show(). But with a specific web browser.
function webui_show_browser(window: SizeInt; const content: PChar; browser: SizeInt): Boolean; stdcall; external;
// Set the window in Kiosk mode (Full screen)
procedure webui_set_kiosk(window: SizeInt; status: Boolean); stdcall; external;
// Wait until all opened windows get closed.
procedure webui_wait; stdcall; external;
// Close a specific window only. The window object will still exist.
procedure webui_close(window: SizeInt); stdcall; external;
// Close a specific window and free all memory resources.
procedure webui_destroy(window: SizeInt); stdcall; external;
// Close all opened windows. webui_wait() will break.
procedure webui_exit; stdcall; external;
// Set the web-server root folder path.
function webui_set_root_folder(window: SizeInt; const path: PChar): Boolean; stdcall; external;
// Set a custom handler to serve files
procedure webui_set_file_handler(window: SizeInt; handler: Pointer); stdcall; external;

// -- Other ---------------------------
// Check a specific window if it's still running
function webui_is_shown(window: SizeInt): Boolean; stdcall; external;
// Set the maximum time in seconds to wait for the browser to start
procedure webui_set_timeout(second: SizeInt); stdcall; external;
// Set the default embedded HTML favicon
procedure webui_set_icon(window: SizeInt; const icon, icon_type: PChar); stdcall; external;
// Allow the window URL to be re-used in normal web browsers
procedure webui_set_multi_access(window: SizeInt; status: Boolean); stdcall; external;

// -- JavaScript ----------------------
// Run JavaScript quickly with no waiting for the response.
procedure webui_run(window: SizeInt; const script: PChar); stdcall; external;
// Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).
function webui_script(window: SizeInt; const script: PChar; timeout: SizeInt; buffer: PChar; buffer_length: SizeInt): Boolean; stdcall; external;
// Chose between Deno and Nodejs runtime for .js and .ts files.
procedure webui_set_runtime(window: SizeInt; runtime: SizeInt); stdcall; external;
// Parse argument as integer.
function webui_get_int(e: Pwebui_event_t): Int64; stdcall; external;
// Parse argument as string.
function webui_get_string(e: Pwebui_event_t): PChar; stdcall; external;
// Parse argument as boolean.
function webui_get_bool(e: Pwebui_event_t): Boolean; stdcall; external;
// Return the response to JavaScript as integer.
procedure webui_return_int(e: Pwebui_event_t; n: Int64); stdcall; external;
// Return the response to JavaScript as string.
procedure webui_return_string(e: Pwebui_event_t; const s: PChar); stdcall; external;
// Return the response to JavaScript as boolean.
procedure webui_return_bool(e: Pwebui_event_t; b: Boolean); stdcall; external;
// Base64 encoding. Use this to safely send text based data to the UI.
function webui_encode(const str: PChar): PChar; stdcall; external;
// Base64 decoding. Use this to safely decode received Base64 text from the UI.
function webui_decode(const str: PChar): PChar; stdcall; external;
// Safely free a buffer allocated by WebUI, for example when using webui_encode().
procedure webui_free(ptr: Pointer); stdcall; external;
// Safely allocate memory using the WebUI memory management system.
function webui_malloc(size: SizeInt): Pointer; stdcall; external;
// Safely send raw data to the UI.
procedure webui_send_raw(window: SizeInt; const func: PChar; raw: Pointer; size: SizeInt); stdcall; external;
// Run the window in hidden mode.
procedure webui_set_hide(window: SizeInt; status: Boolean); stdcall; external;

// -- Interface -----------------------
// Bind a specific html element click event with a function. Empty element means all events.
function webui_interface_bind(window: SizeInt; const element: PChar; func: TWebuiInterfaceEventProc): SizeInt; stdcall; external;
// When using `webui_interface_bind()` you may need this function to easily set your callback response.
procedure webui_interface_set_response(window, event_number: SizeInt; const response: PChar); stdcall; external;
// Check if the app is still running or not.
function webui_interface_is_app_running: Boolean; stdcall; external;
// Get window unique ID
function webui_interface_get_window_id(window: SizeInt): SizeInt; stdcall; external;
// Get a unique ID. Same ID as `webui_bind()`. Return > 0 if bind exists.
function webui_interface_get_bind_id(window: SizeInt; const element: PChar): SizeInt; stdcall; external;


implementation

end.
