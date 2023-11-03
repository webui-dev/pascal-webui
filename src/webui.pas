unit WebUI;

// Make Pascal WebUI compatible with Delphi (actually only DARWIN needs that mode to be compatible)
{$mode delphi}

interface

{$if defined(LINUX)}
uses cthreads;
{$elseif defined(DARWIN)}
uses dynlibs, SysUtils;
{$endif}

const
  //Windows = Shared or static
  //Linux = Static only
  //MacOS = Dynamic (runtime) only

  {$if defined(WINDOWS)}
    // Windows version works with either shared lib or static linked lib
    webuilib = 'webui-2.dll';

    // Uncomment this line if you want to static link WebUI (no .dll dependency)
    //{$define STATICLINK}

    {$ifdef STATICLINK}
      // Change file name if you compile the same project for multiple platforms
      {$linklib webui-2-static.a}
    {$endif}
  {$elseif defined(LINUX)}
    // Linux version is only available as static linked
    {$define STATICLINK}

    {$ifdef STATICLINK}
      // Change file name if you compile the same project for multiple platforms
      {$linklib webui-2-static.a}
    {$endif}
  {$elseif defined(DARWIN)}
    // MacOS version is only available as dynamic loaded lib (in runtime)
    webuilib = 'webui-2.dylib';
  {$endif}

  WEBUI_VERSION = '2.4.0';
  WEBUI_MAX_IDS = 256; // Max windows, servers and threads
  WEBUI_MAX_ARG = 16;  // Max allowed argument's index

{$ifdef STATICLINK}
  {$ifdef WINDOWS}
    {
    Include more required libs for static linking on Windows.

    Order of static libraries does matter.
    If you set improper order, the executable output will have too much imports and dependencies that might not be installed on the target machine.

    "Visual C++ Redistributable for Visual Studio 2015" (blind shot) is required in both shared (DLL) and static linked versions of WebUI.
    The exact dll that has to exist on target Windows installation is "ucrtbase.dll".
    }

    {$linklib libmingwex.a}
    {$linklib libgcc.a}
    {$linklib libkernel32.a}
    {$linklib libadvapi32.a}
    {$linklib libuser32.a}
    {$linklib libmincore.a}
    {$linklib libmsvcrt.a}
    {$linklib libshell32.a}
  {$endif}
{$endif}

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
  size_t = PtrUInt; // in case its not defined (some FPC installations)

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

{$macro on}

{$ifdef STATICLINK}
  {$define imp:=stdcall; external}
{$else}
  {$ifdef DARWIN}
    {$define imp:=inline}
  {$else}
    {$define imp:=stdcall; external webuilib}
  {$endif}
{$endif}

// -- Definitions ---------------------

// Create a new webui window object.
function webui_new_window: size_t; imp;
// Create a new webui window object.
procedure webui_new_window_id(window_number: size_t); imp;
// Get a free window ID that can be used with `webui_new_window_id()`
function webui_get_new_window_id: size_t; imp;
// Bind a specific html element click event with a function. Empty element means all events.
function webui_bind(window: size_t; const element: PChar; func: TWebuiEventProc): size_t; imp;
// Show a window using a embedded HTML, or a file. If the window is already opened then it will be refreshed.
function webui_show(window: size_t; const content: PChar): Boolean; imp;
// Same as webui_show(). But with a specific web browser.
function webui_show_browser(window: size_t; const content: PChar; browser: size_t): Boolean; imp;
// Set the window in Kiosk mode (Full screen)
procedure webui_set_kiosk(window: size_t; status: Boolean); imp;
// Wait until all opened windows get closed.
procedure webui_wait; imp;
// Close a specific window only. The window object will still exist.
procedure webui_close(window: size_t); imp;
// Close a specific window and free all memory resources.
procedure webui_destroy(window: size_t); imp;
// Close all opened windows. webui_wait() will break.
procedure webui_exit; imp;
// Set the web-server root folder path.
function webui_set_root_folder(window: size_t; const path: PChar): Boolean; imp;
// Set the web-server root folder path for all windows. Should be used before `webui_show()`.
function webui_set_default_root_folder(const path: PChar): Boolean; imp;
// Set a custom handler to serve files
procedure webui_set_file_handler(window: size_t; handler: TWebUIFileHandlerProc); imp;
// Check a specific window if it's still running
function webui_is_shown(window: size_t): Boolean; imp;
// Set the maximum time in seconds to wait for the browser to start
procedure webui_set_timeout(second: size_t); imp;
// Set the default embedded HTML favicon
procedure webui_set_icon(window: size_t; const icon, icon_type: PChar); imp;
// Base64 encoding. Use this to safely send text based data to the UI.
function webui_encode(const str: PChar): PChar; imp;
// Base64 decoding. Use this to safely decode received Base64 text from the UI.
function webui_decode(const str: PChar): PChar; imp;
// Safely free a buffer allocated by WebUI, for example when using webui_encode().
procedure webui_free(ptr: Pointer); imp;
// Safely allocate memory using the WebUI memory management system.
function webui_malloc(size: size_t): Pointer; imp;
// Safely send raw data to the UI.
procedure webui_send_raw(window: size_t; const func: PChar; raw: Pointer; size: size_t); imp;
// Run the window in hidden mode.
procedure webui_set_hide(window: size_t; status: Boolean); imp;
// Set the window size.
procedure webui_set_size(window: size_t; width, height: UInt32); imp;
// Set the window position.
procedure webui_set_position(window: size_t; x, y: UInt32); imp;
// Set the web browser profile to use. An empty `name` and `path` means the default user profile. Need to be called before `webui_show()`.
procedure webui_set_profile(window: size_t; const name, path: PChar); imp;
// Get the full current URL
function webui_get_url(window: size_t): PChar; imp;
// Navigate to a specific URL
procedure webui_navigate(window: size_t; url: PChar); imp;
// Free all memory resources. Should be called only at the end.
procedure webui_clean; imp;
// Delete all local web-browser profiles folder. It should be called at the end.
procedure webui_delete_all_profiles; imp;
// Delete a specific window web-browser local folder profile.
procedure webui_delete_profile(window: size_t); imp;
// Get the ID of the parent process (The web browser may re-create another new process).
function webui_get_parent_process_id(window: size_t): size_t; imp;
// Get the ID of the last child process.
function webui_get_child_process_id(window: size_t): size_t; imp;
// Set a custom web-server network port to be used by WebUI.
// This can be useful to determine the HTTP link of `webui.js` in case
// you are trying to use WebUI with an external web-server like NGNIX
function webui_set_port(window, port: size_t): Boolean; imp;

// -- JavaScript ----------------------

// Run JavaScript quickly with no waiting for the response.
procedure webui_run(window: size_t; const script: PChar); imp;
// Run a JavaScript, and get the response back (Make sure your local buffer can hold the response).
function webui_script(window: size_t; const script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean; imp;
// Chose between Deno and Nodejs runtime for .js and .ts files.
procedure webui_set_runtime(window: size_t; runtime: size_t); imp;
// Get an argument as integer at a specific index
function webui_get_int_at(e: PWebUIEvent; index: size_t): Int64; imp;
// Get the first argument as integer
function webui_get_int(e: PWebUIEvent): Int64; imp;
// Get an argument as string at a specific index
function webui_get_string_at(e: PWebUIEvent; index: size_t): PChar; imp;
// Get the first argument as string
function webui_get_string(e: PWebUIEvent): PChar; imp;
// Get an argument as boolean at a specific index
function webui_get_bool_at(e: PWebUIEvent; index: size_t): Boolean; imp;
// Get the first argument as boolean
function webui_get_bool(e: PWebUIEvent): Boolean; imp;
// Get the size in bytes of an argument at a specific index
function webui_get_size_at(e: PWebUIEvent; index: size_t): size_t; imp;
// Get size in bytes of the first argument
function webui_get_size(e: PWebUIEvent): size_t; imp;
// Return the response to JavaScript as integer.
procedure webui_return_int(e: PWebUIEvent; n: Int64); imp;
// Return the response to JavaScript as string.
procedure webui_return_string(e: PWebUIEvent; const s: PChar); imp;
// Return the response to JavaScript as boolean.
procedure webui_return_bool(e: PWebUIEvent; b: Boolean); imp;

// -- SSL/TLS -------------------------

// Set the SSL/TLS certificate and the private key content, both in PEM
// format. This works only with `webui-2-secure` library. If set empty WebUI
// will generate a self-signed certificate.
function webui_set_tls_certificate(const certificate_pem, private_key_pem: PChar): Boolean; imp;

// -- Wrapper's Interface -------------

// Bind a specific html element click event with a function. Empty element means all events.
function webui_interface_bind(window: size_t; const element: PChar; func: TWebUIInterfaceEventProc): size_t; imp;
// When using `webui_interface_bind()` you may need this function to easily set your callback response.
procedure webui_interface_set_response(window, event_number: size_t; const response: PChar); imp;
// Check if the app is still running or not.
function webui_interface_is_app_running: Boolean; imp;
// Get window unique ID
function webui_interface_get_window_id(window: size_t): size_t; imp;
// Get an argument as string at a specific index
function webui_interface_get_string_at(window, event_number, index: size_t): PChar; imp;
// Get an argument as integer at a specific index
function webui_interface_get_int_at(window, event_number, index: size_t): Int64; imp;
// Get an argument as boolean at a specific index
function webui_interface_get_bool_at(window, event_number, index: size_t): Boolean; imp;

{$ifdef DARWIN}
implementation

var
  lib: TLibHandle;

  // -- Definitions ---------------------

  _webui_new_window: function: size_t; stdcall;
  _webui_new_window_id: procedure(window_number: size_t); stdcall;
  _webui_get_new_window_id: function: size_t; stdcall;
  _webui_bind: function(window: size_t; const element: PChar; func: TWebuiEventProc): size_t; stdcall;
  _webui_show: function(window: size_t; const content: PChar): Boolean; stdcall;
  _webui_show_browser: function(window: size_t; const content: PChar; browser: size_t): Boolean; stdcall;
  _webui_set_kiosk: procedure(window: size_t; status: Boolean); stdcall;
  _webui_wait: procedure; stdcall;
  _webui_close: procedure(window: size_t); stdcall;
  _webui_destroy: procedure(window: size_t); stdcall;
  _webui_exit: procedure; stdcall;
  _webui_set_root_folder: function(window: size_t; const path: PChar): Boolean; stdcall;
  _webui_set_default_root_folder: function(const path: PChar): Boolean; stdcall;
  _webui_set_file_handler: procedure(window: size_t; handler: TWebUIFileHandlerProc); stdcall;
  _webui_is_shown: function(window: size_t): Boolean; stdcall;
  _webui_set_timeout: procedure(second: size_t); stdcall;
  _webui_set_icon: procedure(window: size_t; const icon, icon_type: PChar); stdcall;
  _webui_encode: function(const str: PChar): PChar; stdcall;
  _webui_decode: function(const str: PChar): PChar; stdcall;
  _webui_free: procedure(ptr: Pointer); stdcall;
  _webui_malloc: function(size: size_t): Pointer; stdcall;
  _webui_send_raw: procedure(window: size_t; const func: PChar; raw: Pointer; size: size_t); stdcall;
  _webui_set_hide: procedure(window: size_t; status: Boolean); stdcall;
  _webui_set_profile: procedure(window: size_t; const name, path: PChar); stdcall;
  _webui_set_size: procedure(window: size_t; width, height: UInt32); stdcall;
  _webui_set_position: procedure(window: size_t; x, y: UInt32); stdcall;
  _webui_clean: procedure; stdcall;
  _webui_get_url: function(window: size_t): PChar; stdcall;
  _webui_navigate: procedure(window: size_t; url: PChar); stdcall;
  _webui_delete_all_profiles: procedure; stdcall;
  _webui_delete_profile: procedure(window: size_t); stdcall;
  _webui_get_parent_process_id: function(window: size_t): size_t; stdcall;
  _webui_get_child_process_id: function(window: size_t): size_t; stdcall;
  _webui_set_port: function(window, port: size_t): Boolean; stdcall;

  // -- JavaScript ----------------------

  _webui_run: procedure(window: size_t; const script: PChar); stdcall;
  _webui_script: function(window: size_t; const script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean; stdcall;
  _webui_set_runtime: procedure(window: size_t; runtime: size_t); stdcall;
  _webui_get_int_at: function(e: PWebUIEvent; index: size_t): Int64; stdcall;
  _webui_get_int: function(e: PWebUIEvent): Int64; stdcall;
  _webui_get_string_at: function(e: PWebUIEvent; index: size_t): PChar; stdcall;
  _webui_get_string: function(e: PWebUIEvent): PChar; stdcall;
  _webui_get_bool_at: function(e: PWebUIEvent; index: size_t): Boolean; stdcall;
  _webui_get_bool: function(e: PWebUIEvent): Boolean; stdcall;
  _webui_get_size_at: function(e: PWebUIEvent; index: size_t): size_t; stdcall;
  _webui_get_size: function(e: PWebUIEvent): size_t; stdcall;
  _webui_return_int: procedure(e: PWebUIEvent; n: Int64); stdcall;
  _webui_return_string: procedure(e: PWebUIEvent; const s: PChar); stdcall;
  _webui_return_bool: procedure(e: PWebUIEvent; b: Boolean); stdcall;

  // -- SSL/TLS -------------------------

  _webui_set_tls_certificate: function(const certificate_pem, private_key_pem: PChar): Boolean; stdcall;

  // -- Wrapper's Interface -------------

  _webui_interface_bind: function(window: size_t; const element: PChar; func: TWebUIInterfaceEventProc): size_t; stdcall;
  _webui_interface_set_response: procedure(window, event_number: size_t; const response: PChar); stdcall;
  _webui_interface_is_app_running: function: Boolean; stdcall;
  _webui_interface_get_window_id: function(window: size_t): size_t; stdcall;
  _webui_interface_get_string_at: function(window, event_number, index: size_t): PChar; stdcall;
  _webui_interface_get_int_at: function(window, event_number, index: size_t): Int64; stdcall;
  _webui_interface_get_bool_at: function(window, event_number, index: size_t): Boolean; stdcall;

// Aliases to dynamically loaded functions
// Done this way so function (procedure) with no parameters doesnt require to be called with parenthesis "()"

// -- Definitions ---------------------

function webui_new_window: size_t;
begin
  result := _webui_new_window();
end;

procedure webui_new_window_id(window_number: size_t);
begin
  _webui_new_window_id(window_number);
end;

function webui_get_new_window_id: size_t;
begin
  result := _webui_get_new_window_id;
end;

function webui_bind(window: size_t; const element: PChar; func: TWebuiEventProc): size_t;
begin
  result := _webui_bind(window, element, func);
end;

function webui_show(window: size_t; const content: PChar): Boolean;
begin
  result := _webui_show(window, content);
end;

function webui_show_browser(window: size_t; const content: PChar; browser: size_t): Boolean;
begin
  result := _webui_show_browser(window, content, browser);
end;

procedure webui_set_kiosk(window: size_t; status: Boolean);
begin
  _webui_set_kiosk(window, status);
end;

procedure webui_wait;
begin
  _webui_wait();
end;

procedure webui_close(window: size_t);
begin
  _webui_close(window);
end;

procedure webui_destroy(window: size_t);
begin
  _webui_destroy(window);
end;

procedure webui_exit;
begin
  _webui_exit();
end;

function webui_set_root_folder(window: size_t; const path: PChar): Boolean;
begin
  result := _webui_set_root_folder(window, path);
end;

function webui_set_default_root_folder(const path: PChar): Boolean;
begin
  result := _webui_set_default_root_folder(path);
end;

procedure webui_set_file_handler(window: size_t; handler: TWebUIFileHandlerProc);
begin
  _webui_set_file_handler(window, handler);
end;

function webui_is_shown(window: size_t): Boolean;
begin
  result := _webui_is_shown(window);
end;

procedure webui_set_timeout(second: size_t);
begin
  _webui_set_timeout(second);
end;

procedure webui_set_icon(window: size_t; const icon, icon_type: PChar);
begin
  _webui_set_icon(window, icon, icon_type);
end;

function webui_encode(const str: PChar): PChar;
begin
  result := _webui_encode(str);
end;

function webui_decode(const str: PChar): PChar;
begin
  result := _webui_decode(str);
end;

procedure webui_free(ptr: Pointer);
begin
  _webui_free(ptr);
end;

function webui_malloc(size: size_t): Pointer;
begin
  result := _webui_malloc(size);
end;

procedure webui_send_raw(window: size_t; const func: PChar; raw: Pointer; size: size_t);
begin
  _webui_send_raw(window, func, raw, size);
end;

procedure webui_set_hide(window: size_t; status: Boolean);
begin
  _webui_set_hide(window, status);
end;

procedure webui_set_size(window: size_t; width, height: UInt32);
begin
  _webui_set_size(window, width, height);
end;

procedure webui_set_position(window: size_t; x, y: UInt32);
begin
  _webui_set_position(window, x, y);
end;

procedure webui_set_profile(window: size_t; const name, path: PChar);
begin
  _webui_set_profile(window, name, path);
end;

function webui_get_url(window: size_t): PChar;
begin
  result := _webui_get_url(window);
end;

procedure webui_navigate(window: size_t; url: PChar);
begin
  _webui_navigate(window, url);
end;

procedure webui_clean;
begin
  _webui_clean();
end;

procedure webui_delete_all_profiles;
begin
  _webui_delete_all_profiles();
end;

procedure webui_delete_profile(window: size_t);
begin
  _webui_delete_profile(window);
end;

function webui_get_parent_process_id(window: size_t): size_t;
begin
  result := _webui_get_parent_process_id(window);
end;

function webui_get_child_process_id(window: size_t): size_t;
begin
  result := _webui_get_child_process_id(window);
end;

function webui_set_port(window, port: size_t): Boolean;
begin
  result := _webui_set_port(window, port);
end;

// -- JavaScript ----------------------

procedure webui_run(window: size_t; const script: PChar);
begin
  _webui_run(window, script);
end;

function webui_script(window: size_t; const script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean;
begin
  result := _webui_script(window, script, timeout, buffer, buffer_length);
end;

procedure webui_set_runtime(window: size_t; runtime: size_t);
begin
  _webui_set_runtime(window, runtime);
end;

function webui_get_int_at(e: PWebUIEvent; index: size_t): Int64;
begin
  result := _webui_get_int_at(e, index);
end;

function webui_get_int(e: PWebUIEvent): Int64;
begin
  result := _webui_get_int(e);
end;

function webui_get_string_at(e: PWebUIEvent; index: size_t): PChar;
begin
  result := _webui_get_string_at(e, index);
end;

function webui_get_string(e: PWebUIEvent): PChar;
begin
  result := _webui_get_string(e);
end;

function webui_get_bool_at(e: PWebUIEvent; index: size_t): Boolean;
begin
  result := _webui_get_bool_at(e, index);
end;

function webui_get_bool(e: PWebUIEvent): Boolean;
begin
  result := _webui_get_bool(e);
end;

function webui_get_size_at(e: PWebUIEvent; index: size_t): size_t;
begin
  result := _webui_get_size_at(e, index);
end;

function webui_get_size(e: PWebUIEvent): size_t;
begin
  result := _webui_get_size(e);
end;

procedure webui_return_int(e: PWebUIEvent; n: Int64);
begin
  _webui_return_int(e, n);
end;

procedure webui_return_string(e: PWebUIEvent; const s: PChar);
begin
  _webui_return_string(e, s);
end;

procedure webui_return_bool(e: PWebUIEvent; b: Boolean);
begin
  _webui_return_bool(e, b);
end;

// -- SSL/TLS -------------------------

function webui_set_tls_certificate(const certificate_pem, private_key_pem: PChar): Boolean;
begin
  result := _webui_set_tls_certificate(certificate_pem, private_key_pem);
end;

// -- Wrapper's Interface -------------

function webui_interface_bind(window: size_t; const element: PChar; func: TWebUIInterfaceEventProc): size_t;
begin
  result := _webui_interface_bind(window, element, func);
end;

procedure webui_interface_set_response(window, event_number: size_t; const response: PChar);
begin
  _webui_interface_set_response(window, event_number, response);
end;

function webui_interface_is_app_running: Boolean;
begin
  result := _webui_interface_is_app_running();
end;

function webui_interface_get_window_id(window: size_t): size_t;
begin
  result := _webui_interface_get_window_id(window);
end;

function webui_interface_get_string_at(window, event_number, index: size_t): PChar;
begin
  result := _webui_interface_get_string_at(window, event_number, index);
end;

function webui_interface_get_int_at(window, event_number, index: size_t): Int64;
begin
  result := _webui_interface_get_int_at(window, event_number, index);
end;

function webui_interface_get_bool_at(window, event_number, index: size_t): Boolean;
begin
  result := _webui_interface_get_bool_at(window, event_number, index);
end;

initialization
  lib := dynlibs.LoadLibrary(ExtractFilePath(ParamStr(0))+webuilib);
  if lib = 0 then raise Exception.Create('Could not load '+webuilib);

  // -- Definitions ---------------------

  _webui_new_window              :=  dynlibs.GetProcAddress(lib, 'webui_new_window');
  _webui_new_window_id           :=  dynlibs.GetProcAddress(lib, 'webui_new_window_id');
  _webui_get_new_window_id       :=  dynlibs.GetProcAddress(lib, 'webui_get_new_window_id');
  _webui_bind                    :=  dynlibs.GetProcAddress(lib, 'webui_bind');
  _webui_show                    :=  dynlibs.GetProcAddress(lib, 'webui_show');
  _webui_show_browser            :=  dynlibs.GetProcAddress(lib, 'webui_show_browser');
  _webui_set_kiosk               :=  dynlibs.GetProcAddress(lib, 'webui_set_kiosk');
  _webui_wait                    :=  dynlibs.GetProcAddress(lib, 'webui_wait');
  _webui_close                   :=  dynlibs.GetProcAddress(lib, 'webui_close');
  _webui_destroy                 :=  dynlibs.GetProcAddress(lib, 'webui_destroy');
  _webui_exit                    :=  dynlibs.GetProcAddress(lib, 'webui_exit');
  _webui_set_root_folder         :=  dynlibs.GetProcAddress(lib, 'webui_set_root_folder');
  _webui_set_default_root_folder :=  dynlibs.GetProcAddress(lib, 'webui_set_default_root_folder');
  _webui_set_file_handler        :=  dynlibs.GetProcAddress(lib, 'webui_set_file_handler');
  _webui_is_shown                :=  dynlibs.GetProcAddress(lib, 'webui_is_shown');
  _webui_set_timeout             :=  dynlibs.GetProcAddress(lib, 'webui_set_timeout');
  _webui_set_icon                :=  dynlibs.GetProcAddress(lib, 'webui_set_icon');
  _webui_encode                  :=  dynlibs.GetProcAddress(lib, 'webui_encode');
  _webui_decode                  :=  dynlibs.GetProcAddress(lib, 'webui_decode');
  _webui_free                    :=  dynlibs.GetProcAddress(lib, 'webui_free');
  _webui_malloc                  :=  dynlibs.GetProcAddress(lib, 'webui_malloc');
  _webui_send_raw                :=  dynlibs.GetProcAddress(lib, 'webui_send_raw');
  _webui_set_hide                :=  dynlibs.GetProcAddress(lib, 'webui_set_hide');
  _webui_set_profile             :=  dynlibs.GetProcAddress(lib, 'webui_set_profile');
  _webui_set_size                :=  dynlibs.GetProcAddress(lib, 'webui_set_size');
  _webui_set_position            :=  dynlibs.GetProcAddress(lib, 'webui_set_position');
  _webui_clean                   :=  dynlibs.GetProcAddress(lib, 'webui_clean');
  _webui_get_url                 :=  dynlibs.GetProcAddress(lib, 'webui_get_url');
  _webui_navigate                :=  dynlibs.GetProcAddress(lib, 'webui_navigate');
  _webui_delete_all_profiles     :=  dynlibs.GetProcAddress(lib, 'webui_delete_all_profiles');
  _webui_delete_profile          :=  dynlibs.GetProcAddress(lib, 'webui_delete_profile');
  _webui_get_parent_process_id   :=  dynlibs.GetProcAddress(lib, 'webui_get_parent_process_id');
  _webui_get_child_process_id    :=  dynlibs.GetProcAddress(lib, 'webui_get_child_process_id');
  _webui_set_port                :=  dynlibs.GetProcAddress(lib, 'webui_set_port');

  // -- JavaScript ----------------------

  _webui_run           := dynlibs.GetProcAddress(lib, 'webui_run');
  _webui_script        := dynlibs.GetProcAddress(lib, 'webui_script');
  _webui_set_runtime   := dynlibs.GetProcAddress(lib, 'webui_set_runtime');
  _webui_get_int_at    := dynlibs.GetProcAddress(lib, 'webui_get_int_at');
  _webui_get_int       := dynlibs.GetProcAddress(lib, 'webui_get_int');
  _webui_get_string_at := dynlibs.GetProcAddress(lib, 'webui_get_string_at');
  _webui_get_string    := dynlibs.GetProcAddress(lib, 'webui_get_string');
  _webui_get_bool_at   := dynlibs.GetProcAddress(lib, 'webui_get_bool_at');
  _webui_get_bool      := dynlibs.GetProcAddress(lib, 'webui_get_bool');
  _webui_get_size_at   := dynlibs.GetProcAddress(lib, 'webui_get_size_at');
  _webui_get_size      := dynlibs.GetProcAddress(lib, 'webui_get_size');
  _webui_return_int    := dynlibs.GetProcAddress(lib, 'webui_return_int');
  _webui_return_string := dynlibs.GetProcAddress(lib, 'webui_return_string');
  _webui_return_bool   := dynlibs.GetProcAddress(lib, 'webui_return_bool');

  // -- SSL/TLS -------------------------

  _webui_set_tls_certificate := dynlibs.GetProcAddress(lib, 'webui_set_tls_certificate');

  // -- Wrapper's Interface -------------

  _webui_interface_bind           := dynlibs.GetProcAddress(lib, 'webui_interface_bind');
  _webui_interface_set_response   := dynlibs.GetProcAddress(lib, 'webui_interface_set_response');
  _webui_interface_is_app_running := dynlibs.GetProcAddress(lib, 'webui_interface_is_app_running');
  _webui_interface_get_window_id  := dynlibs.GetProcAddress(lib, 'webui_interface_get_window_id');
  _webui_interface_get_string_at  := dynlibs.GetProcAddress(lib, 'webui_interface_get_string_at');
  _webui_interface_get_int_at     := dynlibs.GetProcAddress(lib, 'webui_interface_get_int_at');
  _webui_interface_get_bool_at    := dynlibs.GetProcAddress(lib, 'webui_interface_get_bool_at');

finalization
  if lib <> 0 then dynlibs.FreeLibrary(lib);

{$else}

implementation

{$endif}

end.

