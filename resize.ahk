#Requires AutoHotkey v2.0
#SingleInstance force

; Options
modKey := "alt"
minimizeOnMaximized := true

CoordMode "mouse", "screen"
SetWinDelay 0

monitorWidth := sysget(16)
monitorHeight := sysget(17)

hotif "not filters()"
hotkey modKey " & LButton", move
hotkey modkey " & RButton", resize
hotif

#hotif not filters()

filters() {

    MouseGetPos , , &pid
    ; disable hotkey if desktop is active
    if (WinGetTitle(pid) = "Program Manager" or WinGetTitle(pid) = "") {
        return true
    }

    ; disable hotkey if active window is maximized of minimized
    if (WinGetMinMax(pid) != 0 and not minimizeOnMaximized) {
        return true
    }

    ; disable hotkey if active window is in fullscreen
    if (isFullScreen()) {
        return true
    }

    return false
}


move(_) {
    MouseGetPos &mX, &mY, &pid

    ; Unmaximize if enabled
    if (WinGetMinMax(pid) = 1 and minimizeOnMaximized) {
        WinRestore pid
    }

    WinGetPos &x, &y, &w, &h, pid
    xOffset := x - mX
    yOffset := y - mY

    if IsModPlusKeyHeld("LButton") {
        SetSystemCursor('SIZEALL')
        while (IsModPlusKeyHeld("LButton")) {
            MouseGetPos &mX, &mY
            winmove mX + xOffset, mY + yOffset, , , pid
        }
        RestoreCursor()
    }
}

resize(_)
{
    blockinput "MouseMove"
    ; Get window under mouse
    MouseGetPos &mX, &mY, &pid
    WinGetPos &x, &y, &w, &h, pid

    ; Unmaximize if enabled
    if (WinGetMinMax(pid) = 1 and minimizeOnMaximized)
        WinRestore pid

    ; Determine nearest corner for resizing
    nearestCornerX := (mX - x < w / 2) ? x + 2 : x + w - 1  ; 1 pixel for top-right corner
    nearestCornerY := (mY - y < h / 2) ? y + 2 : y + h - 2  ; Adjusted for 2 pixels inside

    ; Move mouse to the nearest corner
    DllCall("SetCursorPos", "int", nearestCornerX, "int", nearestCornerY)

    send "{click down}"
    blockinput "MouseMoveOff"

    while IsModPlusKeyHeld("RButton") {
        ; The resizing happens as the mouse moves
    }

    send "{click up}"
    WinSetAlwaysOnTop 0, pid
}

IsModPlusKeyHeld(key) {
    return (getKeyState(modKey) and getKeyState(key, "P"))
}


/*!
    Checks if a window is in fullscreen mode.
    ______________________________________________________________________________________________________________

	Usage: isFullScreen()
	Return: True/False

	GitHub Repo: https://github.com/Nigh/isFullScreen
*/
class isFullScreen
{

    static monitors := this.init()
    static init()
    {
        a := []
        loop MonitorGetCount()
        {
            MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
            a.Push({ l: Left, t: Top, r: Right, b: Bottom })
        }
        Return a
    }

    static Call()
    {
        uid := WinExist("A")
        if (!uid) {
            Return False
        }
        wid := "ahk_id " uid
        c := WinGetClass(wid)
        If (uid = DllCall("GetDesktopWindow") Or (c = "Progman") Or (c = "WorkerW")) {
            Return False
        }
        WinGetClientPos(&cx, &cy, &cw, &ch, wid)
        cl := cx
        ct := cy
        cr := cx + cw
        cb := cy + ch
        For , v in this.monitors
        {
            if (cl == v.l and ct == v.t and cr == v.r and cb == v.b) {
                Return True
            }
        }
        Return False
    }
}


; Source:   Serenity - https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
; Modified: iseahound - https://www.autohotkey.com/boards/viewtopic.php?t=75867

SetSystemCursor(Cursor := "", cx := 0, cy := 0) {

    static SystemCursors := Map("APPSTARTING", 32650, "ARROW", 32512, "CROSS", 32515, "HAND", 32649, "HELP", 32651, "IBEAM", 32513, "NO", 32648,
        "SIZEALL", 32646, "SIZENESW", 32643, "SIZENS", 32645, "SIZENWSE", 32642, "SIZEWE", 32644, "UPARROW", 32516, "WAIT", 32514)

    if (Cursor = "") {
        AndMask := Buffer(128, 0xFF), XorMask := Buffer(128, 0)

        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", AndMask, "ptr", XorMask, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
        }
        return
    }

    if (Cursor ~= "^(IDC_)?(?i:AppStarting|Arrow|Cross|Hand|Help|IBeam|No|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait)$") {
        Cursor := RegExReplace(Cursor, "^IDC_")

        if !(CursorShared := DllCall("LoadCursor", "ptr", 0, "ptr", SystemCursors[StrUpper(Cursor)], "ptr"))
            throw Error("Error: Invalid cursor name")

        for CursorName, CursorID in SystemCursors {
            CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", cx, "int", cy, "uint", 0, "ptr")
            DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
        }
        return
    }

    if FileExist(Cursor) {
        SplitPath Cursor, , , &Ext := "" ; auto-detect type
        if !(uType := (Ext = "ani" || Ext = "cur") ? 2 : (Ext = "ico") ? 1 : 0)
            throw Error("Error: Invalid file type")

        if (Ext = "ani") {
            for CursorName, CursorID in SystemCursors {
                CursorHandle := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x10, "ptr")
                DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
            }
        } else {
            if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x8010, "ptr"))
                throw Error("Error: Corrupted file")

            for CursorName, CursorID in SystemCursors {
                CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
                DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID) ; calls DestroyCursor
            }
        }
        return
    }

    throw Error("Error: Invalid file path or cursor name")
}

RestoreCursor() {
    return DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS := 0x57, "uint", 0, "ptr", 0, "uint", 0)
}
