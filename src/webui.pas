unit WebUI;

interface

{$ifdef UNIX}
uses cthreads;
{$endif}

const
  {$if defined(MSWINDOWS)}
    webuilib = 'webui-2.dll';
  {$elseif defined(DARWIN)}
    webuilib = 'webui-2.dyn';
  {$elseif defined(UNIX)}
    webuilib = 'webui-2.so';
  {$endif}

  WEBUI_VERSION = '2.5.0-beta.4';

// -- Enums/Consts --------------------

const
  // Browsers
  WEBUI_NoBrowser     = 0;  // No web browser
  WEBUI_AnyBrowser    = 1;  // Default recommended web browser
  WEBUI_Chrome        = 2;  // Google Chrome
  WEBUI_Firefox       = 3;  // Mozilla Firefox
  WEBUI_Edge          = 4;  // Microsoft Edge
  WEBUI_Safari        = 5;  // Apple Safari
  WEBUI_Chromium      = 6;  // The Chromium Project
  WEBUI_Opera         = 7;  // Opera Browser
  WEBUI_Brave         = 8;  // The Brave Browser
  WEBUI_Vivaldi       = 9;  // The Vivaldi Browser
  WEBUI_Epic          = 10; // The Epic Browser
  WEBUI_Yandex        = 11; // The Yandex Browser
  WEBUI_ChromiumBased = 12; // Any Chromium based browser
  WEBUI_Webview       = 13; // WebView (Non-web-browser)

  // Runtimes
  WEBUI_RUNTIME_None   = 0; // Prevent WebUI from using any runtime for .js and .ts files
  WEBUI_RUNTIME_Deno   = 1; // Use Deno runtime for .js and .ts files
  WEBUI_RUNTIME_NodeJS = 2; // Use Nodejs runtime for .js files
  WEBUI_RUNTIME_Bun    = 3; // Use Bun runtime for .js and .ts files

  // Events
  WEBUI_EVENT_DISCONNECTED = 0; // Window disconnection event
  WEBUI_EVENT_CONNECTED    = 1; // Window connection event
  WEBUI_EVENT_MOUSE_CLICK  = 2; // Mouse click event
  WEBUI_EVENT_NAVIGATION   = 3; // Window navigation event
  WEBUI_EVENT_CALLBACK     = 4; // Function call event

  // Configs
  // Control if `webui_show()`, `webui_show_browser()`, and `webui_show_wv()` wait for window to connect before returning. Default: True
  WEBUI_CONFIG_SHOW_WAIT_CONNECTION  = 0;
  // Control if WebUI processes events in a single thread (`True`) or non-blocking threads (`False`). Default: False
  WEBUI_CONFIG_UI_EVENT_BLOCKING     = 1;
  // Automatically refresh the window UI when any file in the root folder gets changed. Default: False
  WEBUI_CONFIG_FOLDER_MONITOR        = 2;
  // Allow multiple clients to connect to the same window. Default: False
  WEBUI_CONFIG_MULTI_CLIENT          = 3;
  // Allow or prevent WebUI from adding `webui_auth` cookies. Default: True
  WEBUI_CONFIG_USE_COOKIES           = 4;
  // Make webui wait for backend async response via `webui_return_x()`. Default: False
  WEBUI_CONFIG_ASYNCHRONOUS_RESPONSE = 5;

  // Logger levels
  WEBUI_LOGGER_LEVEL_DEBUG = 0; // All logs with all details
  WEBUI_LOGGER_LEVEL_INFO  = 1; // Only general logs
  WEBUI_LOGGER_LEVEL_ERROR = 2; // Only fatal error logs

// -- Structs -------------------------

type
  size_t = NativeUInt;

  TWebUIEvent = packed record
    window: size_t;        // The window object number
    event_type: size_t;    // Event type
    element: PAnsiChar;    // HTML element ID
    event_number: size_t;  // Internal WebUI
    bind_id: size_t;       // Bind ID
    client_id: size_t;     // Client's unique ID
    connection_id: size_t; // Client's connection ID
    cookies: PAnsiChar;    // Client's full cookies
  end;
  PWebUIEvent = ^TWebUIEvent;

  TWebUIEventProc            = procedure(e: PWebUIEvent);
  TWebUIFileHandlerProc      = function(filename: PAnsiChar; len: PInteger): PAnsiChar;
  TWebUIFileHandlerWindowProc = function(window: size_t; filename: PAnsiChar; len: PInteger): Pointer;
  TWebUIInterfaceEventProc   = procedure(window, event_type: size_t; element: PAnsiChar; event_number, bind_id: size_t);
  TWebUICloseHandlerProc     = function(window: size_t): Boolean;
  TWebUILoggerProc           = procedure(level: size_t; const log: PAnsiChar; user_data: Pointer);

// -- Definitions ---------------------

// Create a new webui window object.
function webui_new_window: size_t; stdcall; external webuilib;
// Create a new webui window object using a specified window number.
function webui_new_window_id(window_number: size_t): size_t; stdcall; external webuilib;
// Get a free window ID that can be used with `webui_new_window_id()`
function webui_get_new_window_id: size_t; stdcall; external webuilib;
// Bind a specific html element click event with a function. Empty element means all events.
function webui_bind(window: size_t; const element: PAnsiChar; func: TWebuiEventProc): size_t; stdcall; external webuilib;
// Set user data to a bind, readable later using `webui_get_context()`.
procedure webui_set_context(window: size_t; const element: PAnsiChar; context: Pointer); stdcall; external webuilib;
// Get user data set via `webui_set_context()`.
function webui_get_context(e: PWebUIEvent): Pointer; stdcall; external webuilib;
// Get the recommended web browser ID to use. If you are already using one, this function will return the same ID.
function webui_get_best_browser(window: size_t): size_t; stdcall; external webuilib;
// Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed. All clients.
function webui_show(window: size_t; const content: PAnsiChar): Boolean; stdcall; external webuilib;
// Show a window using embedded HTML, or a file. Single client.
function webui_show_client(e: PWebUIEvent; const content: PAnsiChar): Boolean; stdcall; external webuilib;
// Same as webui_show(). But with a specific web browser.
function webui_show_browser(window: size_t; const content: PAnsiChar; browser: size_t): Boolean; stdcall; external webuilib;
// Start only the local web server and return the URL. No window will be shown.
function webui_start_server(window: size_t; const content: PAnsiChar): PAnsiChar; stdcall; external webuilib;
// Show a WebView window using embedded HTML, or a file. If the window is already open it will be refreshed.
function webui_show_wv(window: size_t; const content: PAnsiChar): Boolean; stdcall; external webuilib;
// Set the window in Kiosk mode (Full screen)
procedure webui_set_kiosk(window: size_t; status: Boolean); stdcall; external webuilib;
// Bring a window to the front and focus it.
procedure webui_focus(window: size_t); stdcall; external webuilib;
// Add user-defined web browser CLI parameters.
procedure webui_set_custom_parameters(window: size_t; params: PAnsiChar); stdcall; external webuilib;
// Set the window with high-contrast support.
procedure webui_set_high_contrast(window: size_t; status: Boolean); stdcall; external webuilib;
// Set whether the window frame is resizable or fixed. Works only on WebView window.
procedure webui_set_resizable(window: size_t; status: Boolean); stdcall; external webuilib;
// Get OS high contrast preference.
function webui_is_high_contrast: Boolean; stdcall; external webuilib;
// Check if a web browser is installed.
function webui_browser_exist(browser: size_t): Boolean; stdcall; external webuilib;
// Wait until all opened windows get closed.
procedure webui_wait; stdcall; external webuilib;
// Wait asynchronously until all opened windows get closed. Returns True if more windows are still open.
function webui_wait_async: Boolean; stdcall; external webuilib;
// Close a specific window only. The window object will still exist.
procedure webui_close(window: size_t); stdcall; external webuilib;
// Minimize a WebView window.
procedure webui_minimize(window: size_t); stdcall; external webuilib;
// Maximize a WebView window.
procedure webui_maximize(window: size_t); stdcall; external webuilib;
// Close a specific client.
procedure webui_close_client(e: PWebUIEvent); stdcall; external webuilib;
// Close a specific window and free all memory resources.
procedure webui_destroy(window: size_t); stdcall; external webuilib;
// Close all opened windows. webui_wait() will break.
procedure webui_exit; stdcall; external webuilib;
// Set the web-server root folder path.
function webui_set_root_folder(window: size_t; const path: PAnsiChar): Boolean; stdcall; external webuilib;
// Set custom browser folder path.
procedure webui_set_browser_folder(const path: PAnsiChar); stdcall; external webuilib;
// Set the web-server root folder path for all windows. Should be used before `webui_show()`.
function webui_set_default_root_folder(const path: PAnsiChar): Boolean; stdcall; external webuilib;
// Set a callback to catch the close event of the WebView window. Must return False to prevent close, True otherwise.
procedure webui_set_close_handler_wv(window: size_t; close_handler: TWebUICloseHandlerProc); stdcall; external webuilib;
// Set a custom handler to serve files. The handler should return full HTTP header and body.
procedure webui_set_file_handler(window: size_t; handler: TWebUIFileHandlerProc); stdcall; external webuilib;
// Set a custom handler to serve files (with window parameter). The handler should return full HTTP header and body.
procedure webui_set_file_handler_window(window: size_t; handler: TWebUIFileHandlerWindowProc); stdcall; external webuilib;
// Check a specific window if it's still running
function webui_is_shown(window: size_t): Boolean; stdcall; external webuilib;
// Set the maximum time in seconds to wait for the browser to start
procedure webui_set_timeout(second: size_t); stdcall; external webuilib;
// Set the default embedded HTML favicon
procedure webui_set_icon(window: size_t; const icon, icon_type: PAnsiChar); stdcall; external webuilib;
// Base64 encoding. Use this to safely send text based data to the UI.
function webui_encode(const str: PAnsiChar): PAnsiChar; stdcall; external webuilib;
// Base64 decoding. Use this to safely decode received Base64 text from the UI.
function webui_decode(const str: PAnsiChar): PAnsiChar; stdcall; external webuilib;
// Safely free a buffer allocated by WebUI, for example when using webui_encode().
procedure webui_free(ptr: Pointer); stdcall; external webuilib;
// Safely allocate memory using the WebUI memory management system.
function webui_malloc(size: size_t): Pointer; stdcall; external webuilib;
// Copy raw data.
procedure webui_memcpy(dest, src: Pointer; count: size_t); stdcall; external webuilib;
// Safely send raw data to the UI. All clients.
procedure webui_send_raw(window: size_t; const func: PAnsiChar; raw: Pointer; size: size_t); stdcall; external webuilib;
// Safely send raw data to the UI. Single client.
procedure webui_send_raw_client(e: PWebUIEvent; const func: PAnsiChar; raw: Pointer; size: size_t); stdcall; external webuilib;
// Run the window in hidden mode.
procedure webui_set_hide(window: size_t; status: Boolean); stdcall; external webuilib;
// Set the window size.
procedure webui_set_size(window: size_t; width, height: UInt32); stdcall; external webuilib;
// Set the window minimum size.
procedure webui_set_minimum_size(window: size_t; width, height: UInt32); stdcall; external webuilib;
// Set the window position.
procedure webui_set_position(window: size_t; x, y: UInt32); stdcall; external webuilib;
// Center the window on the screen. Call before `webui_show()` for better results.
procedure webui_set_center(window: size_t); stdcall; external webuilib;
// Set the web browser profile to use. An empty `name` and `path` means the default user profile. Need to be called before `webui_show()`.
procedure webui_set_profile(window: size_t; const name, path: PAnsiChar); stdcall; external webuilib;
// Set the web browser proxy_server to use. Need to be called before `webui_show()`
procedure webui_set_proxy(window: size_t; const proxy_server: PAnsiChar); stdcall; external webuilib;
// Get the full current URL
function webui_get_url(window: size_t): PAnsiChar; stdcall; external webuilib;
// Open a URL in the native default web browser.
procedure webui_open_url(const url: PAnsiChar); stdcall; external webuilib;
// Allow a specific window address to be accessible from a public network
procedure webui_set_public(window: size_t; status: boolean); stdcall; external webuilib;
// Navigate to a specific URL. All clients.
procedure webui_navigate(window: size_t; url: PAnsiChar); stdcall; external webuilib;
// Navigate to a specific URL. Single client.
procedure webui_navigate_client(e: PWebUIEvent; const url: PAnsiChar); stdcall; external webuilib;
// Free all memory resources. Should be called only at the end.
procedure webui_clean; stdcall; external webuilib;
// Delete all local web-browser profiles folder. It should be called at the end.
procedure webui_delete_all_profiles; stdcall; external webuilib;
// Delete a specific window web-browser local folder profile.
procedure webui_delete_profile(window: size_t); stdcall; external webuilib;
// Get the ID of the parent process (The web browser may re-create another new process).
function webui_get_parent_process_id(window: size_t): size_t; stdcall; external webuilib;
// Get the ID of the last child process.
function webui_get_child_process_id(window: size_t): size_t; stdcall; external webuilib;
// Get the Win32 window HWND. More reliable with WebView than web browser window.
function webui_win32_get_hwnd(window: size_t): Pointer; stdcall; external webuilib;
// Get the window handle (HWND on Win32, GtkWindow on Linux). Works best with WebView.
function webui_get_hwnd(window: size_t): Pointer; stdcall; external webuilib;
// Get the network port of a running window.
function webui_get_port(window: size_t): size_t; stdcall; external webuilib;
// Set a custom web-server network port to be used by WebUI.
function webui_set_port(window, port: size_t): Boolean; stdcall; external webuilib;
// Get an available usable free network port.
function webui_get_free_port: size_t; stdcall; external webuilib;
// Set a custom logger function.
procedure webui_set_logger(func: TWebUILoggerProc; user_data: Pointer); stdcall; external webuilib;
// Control the WebUI behaviour. It's better to call at the beginning.
procedure webui_set_config(option: Integer; status: Boolean); stdcall; external webuilib;
// Control if UI events coming from this window should be processed one a time in a single blocking thread `True`, or process every event in a new non-blocking thread `False`.
procedure webui_set_event_blocking(window: size_t; status: Boolean); stdcall; external webuilib;
// Make a WebView window frameless.
procedure webui_set_frameless(window: size_t; status: Boolean); stdcall; external webuilib;
// Make a WebView window transparent.
procedure webui_set_transparent(window: size_t; status: Boolean); stdcall; external webuilib;
// Get the HTTP mime type of a file.
function webui_get_mime_type(const filename: PAnsiChar): PAnsiChar; stdcall; external webuilib;

// -- SSL/TLS -------------------------

// Set the SSL/TLS certificate and the private key content, both in PEM
// format. This works only with `webui-2-secure` library. If set empty WebUI
// will generate a self-signed certificate.
function webui_set_tls_certificate(const certificate_pem, private_key_pem: PAnsiChar): Boolean; stdcall; external webuilib;

// -- JavaScript ----------------------

// Run JavaScript quickly with no waiting for the response. All clients.
procedure webui_run(window: size_t; const script: PAnsiChar); stdcall; external webuilib;
// Run JavaScript quickly with no waiting for the response. Single client.
procedure webui_run_client(e: PWebUIEvent; const script: PAnsiChar); stdcall; external webuilib;
// Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).
function webui_script(window: size_t; const script: PAnsiChar; timeout: size_t; buffer: PAnsiChar; buffer_length: size_t): Boolean; stdcall; external webuilib;
// Run a JavaScript and get the response back. Single client.
function webui_script_client(e: PWebUIEvent; const script: PAnsiChar; timeout: size_t; buffer: PAnsiChar; buffer_length: size_t): Boolean; stdcall; external webuilib;
// Chose between Deno and Nodejs runtime for .js and .ts files.
procedure webui_set_runtime(window: size_t; runtime: size_t); stdcall; external webuilib;
// Get how many arguments there are in an event.
function webui_get_count(e: PWebUIEvent): size_t; stdcall; external webuilib;
// Get an argument as integer at a specific index
function webui_get_int_at(e: PWebUIEvent; index: size_t): Int64; stdcall; external webuilib;
// Get the first argument as integer
function webui_get_int(e: PWebUIEvent): Int64; stdcall; external webuilib;
// Get an argument as float at a specific index
function webui_get_float_at(e: PWebUIEvent; index: size_t): Double; stdcall; external webuilib;
// Get the first argument as float
function webui_get_float(e: PWebUIEvent): Double; stdcall; external webuilib;
// Get an argument as string at a specific index
function webui_get_string_at(e: PWebUIEvent; index: size_t): PAnsiChar; stdcall; external webuilib;
// Get the first argument as string
function webui_get_string(e: PWebUIEvent): PAnsiChar; stdcall; external webuilib;
// Get an argument as boolean at a specific index
function webui_get_bool_at(e: PWebUIEvent; index: size_t): Boolean; stdcall; external webuilib;
// Get the first argument as boolean
function webui_get_bool(e: PWebUIEvent): Boolean; stdcall; external webuilib;
// Get the size in bytes of an argument at a specific index
function webui_get_size_at(e: PWebUIEvent; index: size_t): size_t; stdcall; external webuilib;
// Get size in bytes of the first argument
function webui_get_size(e: PWebUIEvent): size_t; stdcall; external webuilib;
// Return the response to JavaScript as integer.
procedure webui_return_int(e: PWebUIEvent; n: Int64); stdcall; external webuilib;
// Return the response to JavaScript as float.
procedure webui_return_float(e: PWebUIEvent; f: Double); stdcall; external webuilib;
// Return the response to JavaScript as string.
procedure webui_return_string(e: PWebUIEvent; const s: PAnsiChar); stdcall; external webuilib;
// Return the response to JavaScript as boolean.
procedure webui_return_bool(e: PWebUIEvent; b: Boolean); stdcall; external webuilib;
// Get the last WebUI error code.
function webui_get_last_error_number: size_t; stdcall; external webuilib;
// Get the last WebUI error message.
function webui_get_last_error_message: PAnsiChar; stdcall; external webuilib;

// -- Wrapper's Interface -------------

// Bind a specific html element click event with a function. Empty element means all events.
function webui_interface_bind(window: size_t; const element: PAnsiChar; func: TWebUIInterfaceEventProc): size_t; stdcall; external webuilib;
// When using `webui_interface_bind()` you may need this function to easily set your callback response.
procedure webui_interface_set_response(window, event_number: size_t; const response: PAnsiChar); stdcall; external webuilib;
// Set a file handler response for async `webui_set_file_handler()`.
procedure webui_interface_set_response_file_handler(window: size_t; const response: Pointer; length: Integer); stdcall; external webuilib;
// Check if the app is still running or not.
function webui_interface_is_app_running: Boolean; stdcall; external webuilib;
// Get window unique ID
function webui_interface_get_window_id(window: size_t): size_t; stdcall; external webuilib;
// Get an argument as string at a specific index
function webui_interface_get_string_at(window, event_number, index: size_t): PAnsiChar; stdcall; external webuilib;
// Get an argument as integer at a specific index
function webui_interface_get_int_at(window, event_number, index: size_t): Int64; stdcall; external webuilib;
// Get an argument as float at a specific index
function webui_interface_get_float_at(window, event_number, index: size_t): Double; stdcall; external webuilib;
// Get an argument as boolean at a specific index
function webui_interface_get_bool_at(window, event_number, index: size_t): Boolean; stdcall; external webuilib;
// Get the size in bytes of an argument at a specific index
function webui_interface_get_size_at(window, event_number, index: size_t): size_t; stdcall; external webuilib;
// Show a window using embedded HTML, or a file. Single client.
function webui_interface_show_client(window, event_number: size_t; const content: PAnsiChar): Boolean; stdcall; external webuilib;
// Close a specific client.
procedure webui_interface_close_client(window, event_number: size_t); stdcall; external webuilib;
// Safely send raw data to the UI. Single client.
procedure webui_interface_send_raw_client(window, event_number: size_t; const func: PAnsiChar; raw: Pointer; size: size_t); stdcall; external webuilib;
// Navigate to a specific URL. Single client.
procedure webui_interface_navigate_client(window, event_number: size_t; const url: PAnsiChar); stdcall; external webuilib;
// Run JavaScript without waiting for the response. Single client.
procedure webui_interface_run_client(window, event_number: size_t; const script: PAnsiChar); stdcall; external webuilib;
// Run JavaScript and get the response back. Single client.
function webui_interface_script_client(window, event_number: size_t; const script: PAnsiChar; timeout: size_t; buffer: PAnsiChar; buffer_length: size_t): Boolean; stdcall; external webuilib;

implementation

end.
