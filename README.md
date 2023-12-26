# ahk-resize-windows

> Resizes and moves windows like in dwm and KDE

Standard modkey is meta(windows key)

## Features

### Resize

Resizes the window under the mouse from the closest corner to the mouse.

Modkey + Right click.

### Move

Move the window under the mouse.

Modkey + Left click.

### Fullscreen snaping

Move fullscreen windows between screens.

Drag a window to another screen.

Warning: May crash games if running in fullscreen, works mostly fine in windowed fullscreen.

### Maximize

Maximize windows.

While moving a window double click left mouse button.

### Minimize

Minimize windows.

Modkey + Middle mouse button.

### Opacity

Changes the opacity of the window under the mouse.

Modkey + scroll up/down.

## Configuration

### Disabling features 

To disable a feature comment out the hotkey at the top of the file.

Example disabling opacity

Before:

```ahk
hotif "not filters()"
hotkey modKey " & WheelUp", increaseOpacity
hotkey modKey " & WheelDown", decreaseOpacity
hotkey modKey " & LButton", move
hotkey modkey " & RButton", resize
hotkey modkey " & MButton", minimize
hotif
```

After:

```ahk
hotif "not filters()"
; hotkey modKey " & WheelUp", increaseOpacity
; hotkey modKey " & WheelDown", decreaseOpacity
hotkey modKey " & LButton", move
hotkey modkey " & RButton", resize
hotkey modkey " & MButton", minimize
hotif
```

### Changing modkey

[Keyname refrence](https://www.autohotkey.com/docs/v2/KeyList.htm) \
Edit the top of the script

Example using alt:

```ahk
; Options
modKey := "alt"
```

## Requirements

[Autohotkey v2](https://www.autohotkey.com/) \
Only tested on Windows 10 & 11

## Credits

[IsFullscreen by Nigh](https://github.com/Nigh/isFullScreen) \
[SetSystemCursor by iseahound](https://github.com/iseahound/SetSystemCursor)
