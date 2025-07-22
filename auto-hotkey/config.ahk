#Requires AutoHotkey v2.0

; --- Key Remap ---
LWin::LCtrl
LCtrl::LWin

; Yalnızca <> tuşunu \| ile değiştir (ve tersi) ama AltGr'a dokunmadan
SC056:: Send "{SC029}"
SC029:: Send "{SC056}"

; --- Shortcut Remap ---

; Alt + Backspace → Ctrl + Backspace
!Backspace::^Backspace

; Alt + Left → Ctrl + Left
!Left::^Left

; Alt + Right → Ctrl + Right
!Right::^Right

; Alt + Shift + Left → Ctrl + Shift + Left
!+Left::^+Left

; Alt + Shift + Right → Ctrl + Shift + Right
!+Right::^+Right

; Ctrl + Q → Alt + F4
^q::!F4

; Win + Alt + Space → Win + Space
#!Space::#Space

; --- Ctrl + L → F6 sadece Chrome ve Edge için ---
#HotIf WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe msedge.exe")
^l::F6
~^l up:: Send "{LWin up}"
#HotIf