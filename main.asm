;-----------------------------------------------------------------------------
;Hello, World for Windows bare metal x86 edition
; by Espen Sande Larsen
;-----------------------------------------------------------------------------

;Boilerplate
.386                                    ;All instructions please
.model flat, stdcall                    ;Win32 std
option casemap:none                     ;Do not preserve case for symbols

;Includes

include \masm32\include\windows.inc     ;windows.h
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc

; Libs
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib

; Main entry point
WinMain proto :DWORD, :DWORD, :DWORD, :DWORD

WindowWidth     equ 800
WindowHeight    equ 600

.DATA

ClassName   db  "WCHClass", 0
AppName     db  "WCHs Mini App", 0
Message     db  "Can't believe this is 4K, wonder if I can make it smaller...Yay! got it down to a smidge over 2K!", 0

; Reserve address space
.DATA?
hInstance   HINSTANCE   ?
CommandLine LPSTR       ?

.CODE

; int Main
MainEntry proc
    LOCAL   sui:STARTUPINFOA

    push    NULL
    call    GetModuleHandle
    mov     hInstance, eax
    call    GetCommandLineA
    mov     CommandLine, eax
    lea     eax, sui
    push    eax
    ; Check StartupInfo Show Window Flags
    call    GetStartupInfoA 
    push    SW_SHOWDEFAULT  
    push    CommandLine
    push    NULL
    push    hInstance
    call    WinMain

    push    eax
    call    ExitProcess
MainEntry   endp

; Setup Window Class
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL   wc:WNDCLASSEX
    LOCAL   msg:MSG
    LOCAL   hwnd:HWND

    mov     wc.cbSize, SIZEOF WNDCLASSEX
    mov     wc.style, CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, OFFSET WndProc
    mov     wc.cbClsExtra, 0
    mov     wc.cbWndExtra, 0
    mov     eax, hInstance
    mov     wc.hInstance, eax
    mov     wc.hbrBackground, COLOR_GRAYTEXT + 1
    mov     wc.lpszMenuName, NULL
    mov     wc.lpszClassName, OFFSET ClassName

    push    IDI_EXCLAMATION
    push    NULL
    call    LoadIcon
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax

    push    IDC_ARROW
    push    NULL
    call    LoadCursor
    mov     wc.hCursor, eax

    lea     eax, wc 
    push    eax

    call    RegisterClassEx
    push    NULL
    push    hInstance
    push    NULL
    push    NULL
    push    WindowHeight
    push    WindowWidth
    push    CW_USEDEFAULT
    push    CW_USEDEFAULT
    push    WS_OVERLAPPEDWINDOW + WS_VISIBLE
    push    OFFSET AppName
    push    OFFSET ClassName
    push    0
    call    CreateWindowExA
    cmp     eax, NULL
    je      WinMainRet
    mov     hwnd, eax
    push    eax
    call    UpdateWindow

MessagePump:
    push    0
    push    0
    push    NULL
    lea     eax, msg
    push    eax
    call    GetMessage

    cmp     eax, 0
    je      ExitPump

    lea     eax, msg
    push    eax
    call    TranslateMessage

    lea     eax, msg
    push    eax
    call    DispatchMessage

    jmp MessagePump

ExitPump:
    mov     eax, msg.wParam

WinMainRet:
    ret
WinMain     endp

; Class Implementation Message Handler
WndProc proc    hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL   ps:PAINTSTRUCT
    LOCAL   rect:RECT
    LOCAL   hdc:HDC

    cmp     uMsg, WM_DESTROY
    jne     NotDestroy
    push    0
    call    PostQuitMessage
    xor     eax, eax
    ret
NotDestroy:
    cmp     uMsg, WM_PAINT
    jne     NotPaint
    lea     eax, ps
    push    eax
    push    hWnd
    call    BeginPaint
    mov     hdc, eax

    push    TRANSPARENT
    push    hdc
    call    SetBkMode

    lea     eax, rect
    push    eax
    push    hWnd
    call    GetClientRect
    push    DT_SINGLELINE + DT_CENTER + DT_VCENTER
    lea     eax, rect
    push    eax
    push    -1
    push    OFFSET Message
    push    hdc
    call    DrawText

    lea     eax, ps
    push    eax
    push    hWnd
    call    EndPaint

    xor     eax, eax
    ret
NotPaint:
    push    lParam
    push    wParam
    push    uMsg
    push    hWnd
    call    DefWindowProc
    ret
WndProc endp
END MainEntry