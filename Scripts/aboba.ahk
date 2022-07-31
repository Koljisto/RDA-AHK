
 ; EASY_MACRO
        
 ; Курсор,Мышь,Время,Курсор,Время,
        
 ; 100 100,Левая,1000,200 200,1000,
        
#NoEnv
        
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
        
CustomColor = FFFFFF  ; Can be any RGB color (it will be made transparent below).

        
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow
        
Gui, Color, %CustomColor%
        
Gui, Font, s20  ; Set a large font size (32-point).
        
Gui, Add, Text, vMyText cLime, Воспроизведение...Ctrl+S для ОСТАНОВКИ
        
WinSet, TransColor, %CustomColor% 150
        
Gui, Show, x100 y100 NoActivate
        
loop:=1
        
while(loop = 1)
        
{
 ; Курсор, 100 100
                
MouseMove, 100, 100, 2
                
sleep 100
 ; Мышь, Левая
                
sleep 4
                
Click, down
                
sleep 23
                
Click, up
                
sleep 15
 ; Время, 1000
                        
sleep 1000
 ; Курсор, 200 200
                
MouseMove, 200, 200, 2
                
sleep 100
 ; Время, 1000
                        
sleep 1000
}
		
^s:: ExitApp
		
loop:=0
		
ExitApp
		
return