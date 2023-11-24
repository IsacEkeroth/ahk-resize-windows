# ahk-resize-windows
> Resizes and moves windows like in dwm and KDE

## Features
### Resize
Resizes the window under the mouse from the closest corner to the mouse. 

Press and hold the modkey and press right click to resize.

### Move
Press and hold the modkey and press left click to move it.

#### Fullscreen snaping
Move fullscreen windows between screens

Warning: May crash games if running in fullscreen, works mostly fine in windowed fullscreen.


### Opacity
Changes the opacity of the window under the mouse.

Press and hold the modkey and scroll up and down to adjust the opacity.

## Configuration

### Changing modkey 
[Keyname refrence](https://www.autohotkey.com/docs/v2/KeyList.htm) \
Edit the top of the script 

Example using alt: 
```ahk
; Options
modKey := "alt"
```

## Credits
Fullscreen check by Nigh https://github.com/Nigh/isFullScreen \
SetSystemCursor by iseahound https://github.com/iseahound/SetSystemCursor
