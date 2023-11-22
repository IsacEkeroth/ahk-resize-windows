#Requires AutoHotkey v2.0
#SingleInstance force

; Options
modKey := "lwin"

CoordMode "mouse", "screen"
SetWinDelay 0

monitorWidth := sysget(16)
monitorHeight := sysget(17)

hotif "not filters()"
hotkey modKey " & WheelUp", increaseOpacity
hotkey modKey " & WheelDown", decreaseOpacity
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

    ; disable hotkey if active window is in fullscreen
    if (isFullScreen()) {
        return true
    }

    return false
}


move(_) {
    static lastClickTime := 0
    doubleClickThreshold := 300 ; Adjust as needed

    MouseGetPos &mX, &mY, &pid

    currentTime := A_TickCount
    timeSinceLastClick := currentTime - lastClickTime
    lastClickTime := currentTime

    if (timeSinceLastClick <= doubleClickThreshold) {
        ; Double click detected, toggle maximize/restore
        if (WinGetMinMax(pid) = 1) {
            WinRestore pid
        } else {
            WinMaximize pid
        }
        lastClickTime := 0
        return
    }

    windowState := WinGetMinMax(pid)
    SetSystemCursor('SIZEALL')

    ; Check if the window is maximized or in fullscreen
    if (windowState = 1 || isFullScreen()) {
        initialMonitor := SysGetMonitorContainingPoint(mX, mY)
        while (IsModPlusKeyHeld("LButton")) {
            MouseGetPos &currentMX, &currentMY
            currentMonitor := SysGetMonitorContainingPoint(currentMX, currentMY)

            if (initialMonitor != currentMonitor) {
                ; Snap the window to the new monitor
                SnapWindowToMonitor(pid, currentMonitor)
                initialMonitor := currentMonitor  ; Update the initial monitor to the new one
            }
        }
    } else {

        WinGetPos &x, &y, &w, &h, pid

        xOffset := x - mX
        yOffset := y - mY

        WinSetAlwaysOnTop 1, pid
        while (IsModPlusKeyHeld("LButton")) {
            MouseGetPos &mX, &mY
            winmove mX + xOffset, mY + yOffset, , , pid
        }

        WinSetAlwaysOnTop 0, pid
    }

    RestoreCursor()

}


resize(_) {
    ; Get the initial window position and size
    MouseGetPos &mX, &mY, &pid
    WinGetPos &x, &y, &w, &h, pid

    ; Initialize the cumulative delta
    cumulativeDeltaX := 0
    cumulativeDeltaY := 0

    ; Determine which corners are nearest
    isLeft := mX - x < w // 2
    isTop := mY - y < h // 2

    if (isLeft && isTop) || (!isLeft && !isTop) {
        SetSystemCursor("SIZENWSE") ; Top-left or bottom-right corner
    } else {
        SetSystemCursor("SIZENESW") ; Top-right or bottom-left corner
    }

    while IsModPlusKeyHeld("RButton") {
        MouseGetPos &currentMX, &currentMY

        deltaX := currentMX - mX
        deltaY := currentMY - mY

        cumulativeDeltaX += deltaX
        cumulativeDeltaY += deltaY

        ; Set new dimensions based on the nearest corner
        newW := isLeft ? w - cumulativeDeltaX : w + cumulativeDeltaX
        newH := isTop ? h - cumulativeDeltaY : h + cumulativeDeltaY

        ; Adjust the window position if dragging from the left or top
        newX := isLeft ? x + cumulativeDeltaX : x
        newY := isTop ? y + cumulativeDeltaY : y

        WinMove newX, newY, newW, newH, pid

        mX := currentMX
        mY := currentMY
    }

    RestoreCursor()
}

; This function checks which monitor contains the specified point
SysGetMonitorContainingPoint(x, y) {
    monitors := []
    monitorCount := MonitorGetCount()
    Loop monitorCount {
        MonitorGet(A_Index, &left, &top, &right, &bottom,)
        if (x >= left && x <= right && y >= top && y <= bottom) {
            return A_Index
        }
    }
    return 1 ; Default to primary monitor if not found
}

; This function snaps the window to the specified monitor
SnapWindowToMonitor(windowPID, monitorIndex) {
    ; Get monitor dimensions
    MonitorGet(monitorIndex, &MonitorLeft, &MonitorTop, &MonitorRight, &MonitorBottom)
    ; Restore the window if it is maximized, to be able to move it
    WinRestore("ahk_id " . windowPID)
    WinGetPos(&windowX, &windowY, &windowWidth, &windowHeight, "ahk_id " . windowPID)
    ; Move the window to the center of the new monitor
    WinMove(MonitorLeft + (MonitorRight - MonitorLeft - windowWidth) // 2, MonitorTop + (MonitorBottom - MonitorTop - windowHeight) // 2, windowWidth, windowHeight, "ahk_id " . windowPID)
    ; Maximize the window again
    WinMaximize("ahk_id " . windowPID)
}

increaseOpacity(_) {
    adjustWindowOpacity(10) ; Increase opacity by 10%
}

decreaseOpacity(_) {
    adjustWindowOpacity(-10) ; Decrease opacity by 10%
}

adjustWindowOpacity(change) {
    MouseGetPos , , &pid
    currentOpacity := WinGetTransparent(pid)
    currentOpacity := currentOpacity ? currentOpacity : 255 ; If window is not transparent, set to 100%
    newOpacity := Ceil(max(64, min(255, currentOpacity + (change * 2.55)))) ; Convert to 255-scale
    WinSetTransparent (newOpacity = 255 ? "Off" : newOpacity), pid
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