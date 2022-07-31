#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
FileEncoding, CP65001


posX := []
posY := []
i := 0
IniRead, OutputScriptName, ../Settings.ini, Scripts, scriptname
recording := true
CoordMode, Mouse, Screen
TMI := 70	;in recording
TMR := 100  ;replay
MouseSpeed := 2
CustomColor = FFFFFF  ; Can be any RGB color (it will be made transparent below).
Gui, startnotify: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, startnotify: Color, %CustomColor%
Gui, startnotify: Font, s20  ; Set a large font size (32-point).
Gui, startnotify: Add, Text, vStartText cRed, Нажмите...Ctrl+R для СТАРТА ЗАПИСИ  ; XX & YY serve to auto-size the window.
WinSet, TransColor, %CustomColor% 150
Gui, startnotify: Show, x100 y100 NoActivate

#Persistent
CoordMode, ToolTip, Screen
SetTimer, WatchCursor, 100
return

WatchCursor:
CoordMode, Mouse, Screen ; Coordinates are relative to the desktop (entire screen).
MouseGetPos, x_1, y_1, id_1, control_1
ToolTip, X:%x_1% Y:%y_1%
return

;**************
;START RECORDING
^r::
TmpPath = %A_WorkingDir%\..\Scripts\%OutputScriptName%
file := FileOpen(TmpPath, "w")
file.Write()
file.Close()
Gui, startnotify: Cancel
Gui, startnotify: Hide
Gui, startnotify: Destroy

Gui stopnotify: +LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
Gui, stopnotify: Color, %CustomColor%
Gui, stopnotify: Font, s20  ; Set a large font size (32-point).
Gui, stopnotify: Add, Text, vStopText cLime, Идёт запись...Ctrl+D для ОСТАНОВКИ  ; XX & YY serve to auto-size the window.
WinSet, TransColor, %CustomColor% 150
Gui, stopnotify: Show, x100 y100 NoActivate  ; NoActivate avoids deactivating the currently active window.

recording := true
while(recording = true)
{
	if(i=0)
	{
        ; `nSetWorkingDir %A_ScriptDir%\..\Scripts
		FileAppend,
			(
			`n#NoEnv
			`nCoordMode, Mouse, Screen
			`nSendMode Input
			`n#SingleInstance Force
			`nSetTitleMatchMode 2
			`n#WinActivateForce
			`nSetControlDelay 1
			`nSetWinDelay 0
			`nSetKeyDelay -1
			`nSetMouseDelay -1
			`nSetBatchLines -1
			`nCustomColor = FFFFFF  ; Can be any RGB color (it will be made transparent below).

			`nGui +LastFound +AlwaysOnTop -Caption +ToolWindow
			`nGui, Color, %CustomColor%
			`nGui, Font, s20  ; Set a large font size (32-point).
			`nGui, Add, Text, vMyText cLime, Воспроизведение...Ctrl+S для ОСТАНОВКИ
			`nWinSet, TransColor, %CustomColor% 150
			`nGui, Show, x100 y100 NoActivate
			`nloop:=1
			`nwhile(loop = 1)
			`n{
			), %A_WorkingDir%\..\Scripts\%OutputScriptName%
		; Run, %A_WorkingDir%\mousepos.ahk
	}
	
	
	MouseGetPos, x, y, id_1, control_1
	posX[i] := x
	posY[i] := y

	if(GetKeyState("RButton", "P"))
	{
		FileAppend, 
			(
			`nMouseMove, %x%, %y%, %MouseSpeed%
			`nsleep %TMR%
			`nsleep 4
			`nClick, down Right
			`nsleep 23
			`nClick, up Right
			`nsleep 15
			), %A_WorkingDir%\..\Scripts\%OutputScriptName%
		
	}
	if(GetKeyState("LButton", "P"))
	{
		FileAppend, 
			(
			`nMouseMove, %x%, %y%, %MouseSpeed%
			`nsleep %TMR%
			`nsleep 4
			`nClick, down
			`nsleep 23
			`nClick, up
			`nsleep 15
			), %A_WorkingDir%\..\Scripts\%OutputScriptName%
		
	}
	
	if(GetKeyState("F", "P"))
	{
	  	FileAppend, 
			(
			`nsleep 10
			`nSend {F down}
			`nsleep 23
			`nSend {F up}
			), %A_WorkingDir%\..\Scripts\%OutputScriptName%
	}

	if(GetKeyState("M", "P"))
	{
		FileAppend, 
			(
			`nsleep 10
			`nSend {M down}
			`nsleep 23
			`nSend {M up}
			), %A_WorkingDir%\..\Scripts\%OutputScriptName%
	}
	
	;check mouse moves
	FileAppend, 
		(
		 `nMouseMove, %x%, %y%, %MouseSpeed%
		 `nsleep %TMR%
		), %A_WorkingDir%\..\Scripts\%OutputScriptName%
	sleep %TMI%
	i++
}
return
;************************
^d::  ;exit
recording := false

FileAppend, 
		(
		`n}
		`n^s:: ExitApp
		`nloop:=0
		`nExitApp
		`nreturn
		), %A_WorkingDir%\..\Scripts\%OutputScriptName%

Gui, stopnotify: Cancel
Gui, stopnotify: Hide
Gui, stopnotify: Destroy
ExitApp
return
;********************************