; Window Spy - recreation of the VB6 Window Tools / Window Spy project
; AutoHotkey v1.1+
#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
SetTitleMatchMode, 2
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

global gHwnd := 0, gParent := 0, gAuto := false, gPick := false, gTop := false, gKillPrompt := true

gui, Main:New, +HwndhMain, Window Spy
gui, Main:Margin, 8, 8
gui, Main:Font, s9, Tahoma
gui, Main:Add, GroupBox, x77 y35 w498 h185, Window Details
Gui, Main:Add, Text, x89 y60 w12 cBlue gCopyHwnd, +
Gui, Main:Add, Text, x100 y60 w105, Handle (hWnd):
gui, Main:Add, Text, x207 y60 w350 vHwnd, [none]
gui, Main:Add, Text, x89 y87 w12 cBlue gCopyWinText, +
gui, Main:Add, Text, x100 y87 w105, Text:
gui, Main:Add, Text, x207 y87 w350 vWinText, [none]
gui, Main:Add, Text, x89 y114 w12 cBlue gCopyWinClass, +
gui, Main:Add, Text, x100 y114 w105, Class:
gui, Main:Add, Text, x207 y114 w350 vWinClass, [none]
gui, Main:Add, Text, x89 y141 w12 cBlue gCopyParentClass, +
gui, Main:Add, Text, x100 y141 w105, Parent Class:
gui, Main:Add, Text, x207 y141 w350 vParentClass, N/A
gui, Main:Add, Text, x89 y168 w12 cBlue gCopyParentText, +
gui, Main:Add, Text, x100 y168 w105, Parent Text:
gui, Main:Add, Text, x207 y168 w350 vParentText, N/A
gui, Main:Add, Text, x89 y195 w12 cBlue gCopyParentHwnd, +
gui, Main:Add, Text, x100 y195 w105, Parent hWnd:
gui, Main:Add, Text, x207 y195 w350 vParentHwnd, N/A

gui, Main:Add, Edit, x77 y230 w498 h23 ReadOnly vShow
Gui, Main:Add, Button, x77 y260 w116 h24 gSetWinText, Set Window Text
gui, Main:Add, Edit, x207 y260 w253 h23 vNewWinText
gui, Main:Add, Button, x77 y287 w116 h24 gSetParentText, Set Parent Text
gui, Main:Add, Edit, x207 y287 w253 h23 vNewParentText
Gui, Main:Add, Button, x472 y260 w103 h51 gPickWindow vPickButton, Pick Target`nThen Click It
Gui, Main:Add, Button, x77 y322 w108 h25 gToggleWin, Hide Window
gui, Main:Add, Button, x189 y322 w92 h25 gToggleParent, Hide Parent
gui, Main:Add, Button, x285 y322 w92 h25 gKillWin, Kill Window
gui, Main:Add, Button, x381 y322 w92 h25 gHwndScan, hWnd Scan
gui, Main:Add, Button, x477 y322 w98 h25 gTransparent, Transparent
gui, Main:Add, Button, x77 y351 w108 h25 gShowWin, Show Window
gui, Main:Add, Button, x189 y351 w92 h25 gShowParent, Show Parent
gui, Main:Add, Button, x285 y351 w92 h25 gKillParent, Kill Parent
gui, Main:Add, Button, x381 y351 w92 h25 gCodeWindow, Code...
gui, Main:Add, Button, x477 y351 w98 h25 gOpaque, Opaque
gui, Main:Add, Checkbox, x77 y390 w104 gToggleTop vOnTop, Keep On Top
gui, Main:Add, Checkbox, x188 y390 w89 gToggleAuto vAutoMode, Auto Mode
gui, Main:Add, Checkbox, x284 y390 w88 vKillPrompt Checked, Kill Prompt
gui, Main:Add, Checkbox, x379 y390 w90 gShowHidden vHiddenWins, Hidden List
gui, Main:Add, Text, x8 y423 w575 vStatus, Details of the windows you find.
gui, Main:Show, w585 h450
SetTimer, RefreshAuto, 250
return

MainGuiClose:
ExitApp
MainGuiSize:
if (A_EventInfo = 1)
 return
; Keep the layout usable when resized.
return

PickWindow:
gPick := true
GuiControl, Main:, Status, Picker armed - move to a window and click once.
SetTimer, PickWatch, 30
return

PickWatch:
if !gPick
 return
if GetKeyState("LButton", "P") {
    MouseGetPos,,, windowHwnd, controlHwnd, 2
    if (windowHwnd = hMain)
        return
    hwnd := controlHwnd ? controlHwnd : windowHwnd
    gPick := false
    SetTimer, PickWatch, Off
    Inspect(hwnd)
    GuiControl, Main:, Status, Window captured.
}
return

RefreshAuto:
if gAuto {
    MouseGetPos,,, windowHwnd, controlHwnd, 2
    if (windowHwnd && windowHwnd != hMain)
        Inspect(controlHwnd ? controlHwnd : windowHwnd)
}
return

ToggleAuto:
GuiControlGet, gAuto,, AutoMode
if gAuto
    GuiControl, Main:, Status, Auto Mode active - move the mouse over a window.
else
    GuiControl, Main:, Status, Auto Mode stopped.
return

ToggleTop:
GuiControlGet, gTop,, OnTop
WinSet, AlwaysOnTop, % gTop ? "On" : "Off", ahk_id %hMain%
return

ToggleWin:
if !ValidTarget(gHwnd, "window")
 return
WinGet, state, MinMax, ahk_id %gHwnd%
WinGet, ex, ExStyle, ahk_id %gHwnd%
if DllCall("IsWindowVisible", "ptr", gHwnd)
    WinHide, ahk_id %gHwnd%
else
    WinShow, ahk_id %gHwnd%
return

ToggleParent:
if !ValidTarget(gParent, "parent")
 return
if DllCall("IsWindowVisible", "ptr", gParent)
    WinHide, ahk_id %gParent%
else
    WinShow, ahk_id %gParent%
return

ShowWin:
if ValidTarget(gHwnd, "window")
    WinShow, ahk_id %gHwnd%
return

ShowParent:
if ValidTarget(gParent, "parent")
    WinShow, ahk_id %gParent%
return

KillParent:
if !ValidTarget(gParent, "parent")
 return
GuiControlGet, prompt, Main:, KillPrompt
if prompt {
    MsgBox, 52, Window Spy, Are you sure you want to close this parent window?
    IfMsgBox, No
        return
}
PostMessage, 0x10,,,, ahk_id %gParent%
return

KillWin:
if !ValidTarget(gHwnd, "window")
 return
GuiControlGet, prompt, Main:, KillPrompt
if prompt {
    MsgBox, 52, Window Spy, Are you sure you want to close this window?
    IfMsgBox, No
        return
}
PostMessage, 0x10,,,, ahk_id %gHwnd%
return

SetWinText:
if !ValidTarget(gHwnd, "window")
 return
GuiControlGet, s, Main:, NewWinText
; A window title is changed with SetWindowText. (ControlSetText is only for a child control.)
if !DllCall("SetWindowText", "ptr", gHwnd, "str", s)
    MsgBox, 48, Window Spy, Windows denied the title change. Run Window Spy at the same elevation as the target application.
Inspect(gHwnd)
return

SetParentText:
if !ValidTarget(gParent, "parent")
 return
GuiControlGet, s, Main:, NewParentText
if !DllCall("SetWindowText", "ptr", gParent, "str", s)
    MsgBox, 48, Window Spy, Windows denied the title change. Run Window Spy at the same elevation as the target application.
Inspect(gHwnd)
return

ShowHidden:
GuiControlGet, checked, Main:, HiddenWins
if checked
    ShowHiddenGui()
return

Transparent:
if !ValidTarget(gHwnd, "window")
 return
WinSet, Transparent, 180, ahk_id %gHwnd%
GuiControl, Main:, Status, The selected target is now 70 percent opaque.
return

Opaque:
if !ValidTarget(gHwnd, "window")
 return
WinSet, Transparent, Off, ahk_id %gHwnd%
GuiControl, Main:, Status, The selected target is fully opaque again.
return

CodeWindow:
if !ValidTarget(gHwnd, "window")
 return
Gui, Code:New, +Resize, Window Spy - Code
gui, Code:Font, s9, Tahoma
gui, Code:Add, GroupBox, x10 y8 w565 h48, Code Generator
gui, Code:Add, Radio, x25 y29 vCodeLang Checked gGenerateCode, AutoHotkey
gui, Code:Add, Radio, x145 y29 vLangVB gGenerateCode, Visual Basic
gui, Code:Add, Radio, x270 y29 vLangCpp gGenerateCode, C++
gui, Code:Add, Edit, x12 y68 w560 h120 ReadOnly vGeneratedCode
gui, Code:Add, Button, x12 y200 w100 gGenerateCode, Generate
gui, Code:Add, Button, x118 y200 w100 gCopyCode, Copy
gui, Code:Add, Button, x472 y200 w100 gCodeClose, Close
gui, Code:Show, w585 h240
Gosub, GenerateCode
return

GenerateCode:
GuiControlGet, vbSelected, Code:, LangVB
GuiControlGet, cppSelected, Code:, LangCpp
lang := vbSelected ? 2 : (cppSelected ? 3 : 1)
code := MakeCode(gHwnd, gParent, lang)
GuiControl, Code:, GeneratedCode, %code%
return

CopyCode:
GuiControlGet, code, Code:, GeneratedCode
Clipboard := code
return
CodeClose:
CodeGuiClose:
Gui, Code:Destroy
return

CopyHwnd:
CopyValue("Hwnd")
return
CopyWinText:
CopyValue("WinText")
return
CopyWinClass:
CopyValue("WinClass")
return
CopyParentClass:
CopyValue("ParentClass")
return
CopyParentText:
CopyValue("ParentText")
return
CopyParentHwnd:
CopyValue("ParentHwnd")
return

HwndScan:
Gui, Scan:New, +Resize, Window Spy - Handle Scanner
gui, Scan:Add, Text, x12 y12, Lists all current top-level windows and their controls.
gui, Scan:Add, Button, x365 y8 w90 gDoScan, Scan
gui, Scan:Add, Button, x465 y8 w90 gClearScan, Clear
gui, Scan:Add, ListBox, x12 y40 w558 h280 vScanList gScanSelect
Gui, Scan:Show, w585 h335
Gosub, DoScan
return
DoScan:
GuiControl, Scan:, ScanList, |
WinGet, windowList, List
Loop, %windowList% {
 hwnd := windowList%A_Index%
 AddScanItem(hwnd)
 WinGet, controls, ControlListHwnd, ahk_id %hwnd%
 Loop, Parse, controls, `n
  if A_LoopField
   AddScanItem(A_LoopField)
}
return
ClearScan:
GuiControl, Scan:, ScanList, |
return
ScanSelect:
GuiControlGet, line, Scan:, ScanList
if (line = "")
 return
StringSplit, p, line, %A_Space%
Inspect(p1)
return
ScanGuiClose:
Gui, Scan:Destroy
return

Inspect(hwnd) {
 global gHwnd, gParent
 if !hwnd || !DllCall("IsWindow", "ptr", hwnd)
  return
 gHwnd := hwnd
 WinGetTitle, title, ahk_id %hwnd%
 WinGetClass, cls, ahk_id %hwnd%
 parent := DllCall("GetParent", "ptr", hwnd, "ptr")
 gParent := parent
 pcls := "N/A", ptitle := "N/A", phwnd := "N/A"
 if parent {
  WinGetClass, pcls, ahk_id %parent%
  WinGetTitle, ptitle, ahk_id %parent%
  if (ptitle = "")
   ptitle := "[null]"
  phwnd := parent
 }
 if (title = "")
  title := "[null]"
 GuiControl, Main:, Hwnd, %hwnd%
 GuiControl, Main:, WinText, %title%
 GuiControl, Main:, WinClass, %cls%
 GuiControl, Main:, ParentClass, %pcls%
 GuiControl, Main:, ParentText, %ptitle%
 GuiControl, Main:, ParentHwnd, %phwnd%
 GuiControl, Main:, Show, %hwnd%
}

CopyValue(controlName) {
 GuiControlGet, value, Main:, %controlName%
 Clipboard := value
 GuiControl, Main:, Show, %value%
}

ValidTarget(hwnd, what) {
 if hwnd && DllCall("IsWindow", "ptr", hwnd)
  return true
 MsgBox, 48, Window Spy, There is no valid %what% selected.
 return false
}

MakeCode(hwnd, parent, language := 1) {
 WinGetClass, cls, ahk_id %hwnd%
 WinGetTitle, title, ahk_id %hwnd%
 WinGetClass, pcls, ahk_id %parent%
 q := Chr(34)
 if (language = 2) {
  if parent
   return "Dim ParentWin As Long`nDim ChildWin As Long`nParentWin = FindWindow(" . q . pcls . q . ", " . q . title . q . ")`nChildWin = FindWindowEx(ParentWin, 0, " . q . cls . q . ", vbNullString)"
  return "Dim WindowToFind As Long`nWindowToFind = FindWindow(" . q . cls . q . ", " . q . title . q . ")"
 }
 if (language = 3) {
  if parent
   return "HWND parent = FindWindow(" . q . pcls . q . ", " . q . title . q . ");`nHWND child = FindWindowEx(parent, NULL, " . q . cls . q . ", NULL);"
  return "HWND window = FindWindow(" . q . cls . q . ", " . q . title . q . ");"
 }
 if parent
  return "parent := WinExist(" . q . "ahk_class " . pcls . q . ")`ncontrol := " . q . cls . q . "`ntitle := " . q . title . q
 return "hwnd := WinExist(" . q . "ahk_class " . cls . q . ")"
}

AddScanItem(hwnd) {
 if !DllCall("IsWindow", "ptr", hwnd)
  return
 WinGetClass, cls, ahk_id %hwnd%
 WinGetTitle, title, ahk_id %hwnd%
 if (title = "")
  title := "[null]"
 GuiControl, Scan:, ScanList, % hwnd " - " cls " - " title
}

ShowHiddenGui() {
 global
 Gui, Hidden:New, +AlwaysOnTop, Window Spy - Hidden Windows
 Gui, Hidden:Add, ListBox, x10 y10 w400 h230 vHiddenList
 WinGet, list, List
 Loop, %list% {
  id := list%A_Index%
  if !DllCall("IsWindowVisible", "ptr", id) {
   WinGetTitle, t, ahk_id %id%
   GuiControl, Hidden:, HiddenList, %id% " - " t
  }
 }
 Gui, Hidden:Add, Button, x10 y248 w100 gRestoreHidden, Restore
 Gui, Hidden:Show, w425 h285
}
RestoreHidden:
GuiControlGet, row, Hidden:, HiddenList
StringSplit, p, row, %A_Space%
if p1
 WinShow, ahk_id %p1%
return
HiddenGuiClose:
Gui, Hidden:Destroy
return

#IfWinActive, Window Spy
^c::
GuiControlGet, val, Main:, Show
Clipboard := val
return
#IfWinActive
