unit WebUI;

interface

const
  WEBUI_VERSION = '2.3.0';
  WEBUI_MAX_IDS = 512;

type
  size_t = PtrUInt;
  PChar = PAnsiChar;
  
    //Возможные типы событий
  webui_events = (
    WEBUI_EVENT_DISCONNECTED, // 0. Событие отключения окна
    WEBUI_EVENT_CONNECTED, // 1. Событие подключения окна
    WEBUI_EVENT_MULTI_CONNECTION, // 2. Событие нового подключения окна
    WEBUI_EVENT_UNWANTED_CONNECTION, // 3. Событие нового нежелательного подключения окна
    WEBUI_EVENT_MOUSE_CLICK, // 4. Событие клика мыши
    WEBUI_EVENT_NAVIGATION, // 5. Событие навигации окна
    WEBUI_EVENT_CALLBACK // 6. Событие вызова функции
  );

  // Структура события
  Pwebui_event_t = ^webui_event_t;
  webui_event_t = record
    window: size_t;
    event_type: size_t;
    element: PChar;
    data: PChar;
    event_number: size_t;
  end;
  TWebuiEventProc = procedure(e: Pwebui_event_t);
  TWebuiInterfaceEventProc = procedure(window, event_type: size_t; element, data: PChar; event_number: size_t);

function webui_new_window: size_t; cdecl;
procedure webui_new_window_id(window_number: size_t); cdecl;
function webui_get_new_window_id: size_t; cdecl;
function webui_bind(window: size_t; element: PChar; func: TWebuiEventProc): size_t; cdecl;
function webui_show(window: size_t; content: PChar): Boolean; cdecl;
function webui_show_browser(window: size_t; content: PChar; browser: size_t): Boolean; cdecl;
procedure webui_set_kiosk(window: size_t; status: Boolean); cdecl;
procedure webui_wait; cdecl;
procedure webui_close(window: size_t); cdecl;
procedure webui_destroy(window: size_t); cdecl;
procedure webui_exit; cdecl;
function webui_set_root_folder(window: size_t; path: PChar): Boolean; cdecl;
function webui_is_shown(window: size_t): Boolean; cdecl;
procedure webui_set_timeout(second: size_t); cdecl;
procedure webui_set_icon(window: size_t; icon: PChar; icon_type: PChar); cdecl;
procedure webui_set_multi_access(window: size_t; status: Boolean); cdecl;
procedure webui_run(window: size_t; script: PChar); cdecl;
function webui_script(window: size_t; script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean; cdecl;
procedure webui_set_runtime(window: size_t; runtime: size_t); cdecl;
function webui_get_int(e: Pwebui_event_t): Int64; cdecl;
function webui_get_string(e: Pwebui_event_t): PChar; cdecl;
function webui_get_bool(e: Pwebui_event_t): Boolean; cdecl;
procedure webui_return_int(e: Pwebui_event_t; n: Int64); cdecl;
procedure webui_return_string(e: Pwebui_event_t; s: PChar); cdecl;
procedure webui_return_bool(e: Pwebui_event_t; b: Boolean); cdecl;
function webui_encode(str: PChar): PChar; cdecl;
function webui_decode(str: PChar): PChar; cdecl;
procedure webui_free(ptr: Pointer); cdecl;
function webui_interface_bind(window: size_t; element: PChar; func: TWebuiInterfaceEventProc): size_t; cdecl;
procedure webui_interface_set_response(window: size_t; event_number: size_t; response: PChar); cdecl;
function webui_interface_is_app_running: Boolean; cdecl;
function webui_interface_get_window_id(window: size_t): size_t; cdecl;
function webui_interface_get_bind_id(window: size_t; element: PChar): size_t; cdecl;

implementation

const
  WebUILib = 'webui'; // имя библиотеки WebUI

function webui_new_window: size_t; cdecl; external WebUILib;
procedure webui_new_window_id(window_number: size_t); cdecl; external WebUILib;
function webui_get_new_window_id: size_t; cdecl; external WebUILib;
function webui_bind(window: size_t; element: PChar; func: TWebuiEventProc): size_t; cdecl; external WebUILib;
function webui_show(window: size_t; content: PChar): Boolean; cdecl; external WebUILib;
function webui_show_browser(window: size_t; content: PChar; browser: size_t): Boolean; cdecl; external WebUILib;
procedure webui_set_kiosk(window: size_t; status: Boolean); cdecl; external WebUILib;
procedure webui_wait; cdecl; external WebUILib;
procedure webui_close(window: size_t); cdecl; external WebUILib;
procedure webui_destroy(window: size_t); cdecl; external WebUILib;
procedure webui_exit; cdecl; external WebUILib;
function webui_set_root_folder(window: size_t; path: PChar): Boolean; cdecl; external WebUILib;
function webui_is_shown(window: size_t): Boolean; cdecl; external WebUILib;
procedure webui_set_timeout(second: size_t); cdecl; external WebUILib;
procedure webui_set_icon(window: size_t; icon: PChar; icon_type: PChar); cdecl; external WebUILib;
procedure webui_set_multi_access(window: size_t; status: Boolean); cdecl; external WebUILib;
procedure webui_run(window: size_t; script: PChar); cdecl; external WebUILib;
function webui_script(window: size_t; script: PChar; timeout: size_t; buffer: PChar; buffer_length: size_t): Boolean; cdecl; external WebUILib;
procedure webui_set_runtime(window: size_t; runtime: size_t); cdecl; external WebUILib;
function webui_get_int(e: Pwebui_event_t): Int64; cdecl; external WebUILib;
function webui_get_string(e: Pwebui_event_t): PChar; cdecl; external WebUILib;
function webui_get_bool(e: Pwebui_event_t): Boolean; cdecl; external WebUILib;
procedure webui_return_int(e: Pwebui_event_t; n: Int64); cdecl; external WebUILib;
procedure webui_return_string(e: Pwebui_event_t; s: PChar); cdecl; external WebUILib;
procedure webui_return_bool(e: Pwebui_event_t; b: Boolean); cdecl; external WebUILib;
function webui_encode(str: PChar): PChar; cdecl; external WebUILib;
function webui_decode(str: PChar): PChar; cdecl; external WebUILib;
procedure webui_free(ptr: Pointer); cdecl; external WebUILib;
function webui_interface_bind(window: size_t; element: PChar; func: TWebuiInterfaceEventProc): size_t; cdecl; external WebUILib;
procedure webui_interface_set_response(window: size_t; event_number: size_t; response: PChar); cdecl; external WebUILib;
function webui_interface_is_app_running: Boolean; cdecl; external WebUILib;
function webui_interface_get_window_id(window: size_t): size_t; cdecl; external WebUILib;
function webui_interface_get_bind_id(window: size_t; element: PChar): size_t; cdecl; external WebUILib;

end.
