#Requires AutoHotkey v2.0
#SingleInstance force

; Options
modKey := "alt"
minimizeOnMaximized := true

CoordMode "mouse", "screen"

monitorWidth := sysget(16)
monitorHeight := sysget(17)

hotif "not filters()"
hotkey modKey " & LButton", move
hotkey modkey " & RButton", resize
hotif

#hotif not filters()

filters() {

    MouseGetPos ,, &pid
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
    MouseGetPos &mX,&mY,&pid

    ; Unmaximize if enabled
    if (WinGetMinMax(pid) = 1 and minimizeOnMaximized) {
        WinRestore pid
        Sleep(100)
    }

    WinGetPos &x, &y, &w, &h, pid
    
    xOffset := x - mX
    yOffset := y - mY

    while getKeyState(modkey) and getKeyState("LButton", "P") {
        MouseGetPos &mX,&mY
        winmove mX + xOffset, mY + yOffset, ,,pid
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

    while getKeyState(modkey) and getKeyState("RButton", "P") {
        ; The resizing happens as the mouse moves
    }

    send "{click up}"
    WinSetAlwaysOnTop 0, pid
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

	static monitors:=this.init()
	static init()
	{
		a:=[]
		loop MonitorGetCount()
		{
			MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
			a.Push({l:Left,t:Top,r:Right,b:Bottom})
		}
		Return a
	}

	static Call()
	{
		uid:=WinExist("A")
		if(!uid){
			Return False
		}
		wid:="ahk_id " uid
		c:=WinGetClass(wid)
		If (uid = DllCall("GetDesktopWindow") Or (c = "Progman") Or (c = "WorkerW")){
			Return False
		}
		WinGetClientPos(&cx,&cy,&cw,&ch,wid)
		cl:=cx
		ct:=cy
		cr:=cx+cw
		cb:=cy+ch
		For , v in this.monitors
		{
			if(cl==v.l and ct==v.t and cr==v.r and cb==v.b){
				Return True
			}
		}
		Return False
	}
}
