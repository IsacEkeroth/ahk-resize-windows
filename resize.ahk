#Requires AutoHotkey v2.0
#SingleInstance force

~^s::reload

modkey := "alt"
minimizeOnMaximized := true

hotkey "~" modkey, modkeyCheck
hotkey modkey " & RButton", main

filters(pid) {
    ; disable hotkey if desktop is active
    if (WinGetTitle(pid) = "Program Manager") {
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

modkeyCheck(_)
{
    ; Get window under mouse
    MouseGetPos ,, &pid

    if (filters(pid)) {
        hotkey modkey " & RButton", "Off"
        return
    }

    hotkey modkey " & RButton", "On"

    ; Keep script from activating again changing focus
    while GetKeyState(modkey) {
        sleep 100
    }

}

main(_)
{
    ; Get window under mouse
    MouseGetPos ,, &pid

    if (filters(pid)) {
        return
    }

    ; Minimize if enabled
    if (WinGetMinMax(pid) = 1 and minimizeOnMaximized) {
        WinGetPos &x, &y,,, pid
        WinRestore pid
        WinMove x, y,,pid
    }

    ; moves mouse to corner of the window and resizes until modkey is let go
    WinGetPos &x, &y,&w, &h, pid
    DllCall("SetCursorPos", "int", x + w, "int", y + h)


    while GetKeyState(modkey) {
        MouseGetPos &xpos, &ypos
        WinMove x, y, xpos, ypos, pid
    }
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
