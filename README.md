# ahk-resize-windows
> Resizes and moves windows like in dwm and KDE

## Usage
### Resize
Press and hold the modkey(Standard is alt) and press right click to resize

### Move
Press and hold the modkey(Standard is alt) and press left click to move
## Options
### Modkey
To change the modkey Change the string on the fifth line
example using control: 
```ahk
; Options
modKey := "ctrl"
minimizeOnMaximized := true
```
[Keyname refrence](https://www.autohotkey.com/docs/v2/KeyList.htm)
### Maximize behaivour

## Note 
### inconsistent resizing
Block input may not work correctly if not ran as administrator.

### Choppy move
As far as I know this is a limitation of ahk or the underlying windows apis for moving windows.

## Credits
fullscreen check by Nigh https://github.com/Nigh/isFullScreen
