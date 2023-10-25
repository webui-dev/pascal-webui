unit WebUI;

interface

const
  {$ifdef WINDOWS}
  libext = '.dll'; // Windows
  {$elseif defined(DARWIN)}
  libext = '.dyn'; // MacOS
  {$else}
  libext = '.so';  // Linux
  {$endif}

  webuilib = 'webui-2'+libext;
  WEBUI_VERSION = '2.4.0 (Beta)';
  WEBUI_MAX_IDS = 256; // Max windows, servers and threads
  WEBUI_MAX_ARG = 16;  // Max allowed argument's index

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

  // Runtimes
  WEBUI_RUNTIME_None   = 0; // Prevent WebUI from using any runtime for .js and .ts files
  WEBUI_RUNTIME_Deno   = 1; // Use Deno runtime for .js and .ts files
  WEBUI_RUNTIME_NodeJS = 2; // Use Nodejs runtime for .js files

  // Events
  WEBUI_EVENT_DISCONNECTED = 0; // Window disconnection event
  WEBUI_EVENT_CONNECTED    = 1; // Window connection event
  WEBUI_EVENT_MOUSE_CLICK  = 2; // Mouse click event
  WEBUI_EVENT_NAVIGATION   = 3; // Window navigation event
  WEBUI_EVENT_CALLBACK     = 4; // Function call event

// -- Structs -------------------------

type
  size_t = QWord; // in case its not defined (some FPC installations); QWord since WebUI is x64 only

{$packrecords C}

type
  TWebUIEvent = record
    window: size_t;       // The window object number
    event_type: size_t;   // Event type
    element: PChar;       // HTML element ID
    event_number: size_t; // Internal WebUI
    bind_id: size_t;      // Bind ID
  end;
  PWebUIEvent = ^TWebUIEvent;

  TWebUIEventProc = procedure(e: PWebUIEvent);
  TWebUIFileHandlerProc = function(filename: PChar; len: PInteger): PChar;
  TWebUIInterfaceEventProc = procedure(window, event_type: size_t; element: PChar; event_number, bind_id: size_t);

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
function webui_set_default_root_folder(const path: PChar): Boolean; stdcall; external webuilib; 
// Set a custom handler to serve files
procedure webui_set_file_handler(window: size_t; handler: TWebUIFileHandlerProc); stdcall; external webuilib;
// Check a specific window if it's still running
function webui_is_shown(window: size_t): Boolean; stdcall; external webuilib;
// Set the maximum time in seconds to wait for the browser to start
procedure webui_set_timeout(second: size_t); stdcall; external webuilib;
// Set the default embedded HTML favicon
procedure webui_set_icon(window: size_t; const icon, icon_type: PChar); stdcall; external webuilib;
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
// Set the web browser profile to use. An empty `name` and `path` means the default user profile. Need to be called before `webui_show()`.
procedure webui_set_profile(window: size_t; const name, path: PChar); stdcall; external webuilib;
// Get the full current URL
function webui_get_url(window: size_t): PChar; stdcall; external webuilib;
// Navigate to a specific URL
procedure webui_navigate(window: size_t; url: PChar); stdcall; external webuilib;
// Delete all local web browser profile's folder
procedure webui_clean; stdcall; external webuilib;
// Delete all local web-browser profiles folder. It should be called at the end.
procedure webui_delete_all_profiles; stdcall; external webuilib;
// Delete a specific window web-browser local folder profile.
procedure webui_delete_profile(window: size_t); stdcall; external webuilib;
// Get the ID of the parent process (The web browser may re-create another new process).
function webui_get_parent_process_id(window: size_t): size_t; stdcall; external webuilib;
// Get the ID of the last child process.
function webui_get_child_process_id(window: size_t): size_t; stdcall; external webuilib;

// -- JavaScript ----------------------

// Run JavaScript quickly with no waiting for the response.
procedure webui_run(window: size_t; const script: PChar); stdcall; external webuilib;
// Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).
function webui_script(window: size_t; const script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean; stdcall; external webuilib;
// Chose between Deno and Nodejs runtime for .js and .ts files.
procedure webui_set_runtime(window: size_t; runtime: size_t); stdcall; external webuilib;
// Get an argument as integer at a specific index
function webui_get_int_at(e: PWebUIEvent; index: size_t): Int64; stdcall; external webuilib;
// Get the first argument as integer
function webui_get_int(e: PWebUIEvent): Int64; stdcall; external webuilib;
// Get an argument as string at a specific index
function webui_get_string_at(e: PWebUIEvent; index: size_t): PChar; stdcall; external webuilib;
// Get the first argument as string
function webui_get_string(e: PWebUIEvent): PChar; stdcall; external webuilib;
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
// Return the response to JavaScript as string.
procedure webui_return_string(e: PWebUIEvent; const s: PChar); stdcall; external webuilib;
// Return the response to JavaScript as boolean.
procedure webui_return_bool(e: PWebUIEvent; b: Boolean); stdcall; external webuilib;

// -- Wrapper's Interface -------------

// Bind a specific html element click event with a function. Empty element means all events.
function webui_interface_bind(window: size_t; const element: PChar; func: TWebUIInterfaceEventProc): size_t; stdcall; external webuilib;
// When using `webui_interface_bind()` you may need this function to easily set your callback response.
procedure webui_interface_set_response(window, event_number: size_t; const response: PChar); stdcall; external webuilib;
// Check if the app is still running or not.
function webui_interface_is_app_running: Boolean; stdcall; external webuilib;
// Get window unique ID
function webui_interface_get_window_id(window: size_t): size_t; stdcall; external webuilib;
// Get an argument as string at a specific index
function webui_interface_get_string_at(window, event_number, index: size_t): Pchar; stdcall; external webuilib;
// Get an argument as integer at a specific index
function webui_interface_get_int_at(window, event_number, index: size_t): Int64; stdcall; external webuilib;
// Get an argument as boolean at a specific index
function webui_interface_get_bool_at(window, event_number, index: size_t): Boolean; stdcall; external webuilib;

implementation

end.

