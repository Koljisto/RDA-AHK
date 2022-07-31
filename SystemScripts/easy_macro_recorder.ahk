#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
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
IniRead, OutputScriptName, ../Settings.ini, Scripts, scriptname
ShowToolTip := False
IsEasyGenerator := False
ArrayOfCommands := ["Время"]
TmpArrayOfCommands := []
ArrayOfParams := ["1000"]
TmpArrayOfParams := []

Gui, EasyScriptGui: New
Gui, +LastFound +AlwaysOnTop
Gui, Add, Text, x12 y9 w60 h20, %OutputScriptName%
Gui, Add, ListBox, x12 y29 w150 h300 vCommandsListBox gChangeLineCommand, 1, Время`, 1000|2, Время`, 1000|3, Время`, 1000|
Gui, Add, Button, x12 y329 w70 h30 gAddNewLine, Добавить
Gui, Add, Button, x92 y329 w70 h30 gDeleteSelectLine, Убрать
Gui, Add, Text, x172 y9 w80 h20 +Left, Параметры:
Gui, Add, Text, x172 y29 w60 h20 +Left, Команда:
Gui, Add, ComboBox, x232 y29 w80 h20 r4 vComboBoxCommandChoose gChangeCommandAttr, Мышь|Курсор|Клавиша|Время
Gui, Add, Text, x172 y49 w60 h20 +Left, Параметр:
Gui, Add, Edit, x232 y49 w80 h20 vParamEdit gChangeCommandAttr, 0
Gui, Add, Button, x172 y69 w90 h30 gSaveScript, Сохранить
Gui, Add, CheckBox, x322 y29 w150 h20 vActivateShowMouse, Показывать координаты
; Generated using SmartGUI Creator 4.0
Gui, Show, x118 y90 h379 w479, Easy Script

Loop, Read, %A_WorkingDir%\..\Scripts\%OutputScriptName%
{
    If (A_Index == 2 And SubStr(A_LoopReadLine, 4) == "EASY_MACRO" And !IsEasyGenerator)
    {
        IsEasyGenerator := True
    } Else
    {
        If (A_Index > 2 And !IsEasyGenerator)
        {
            Break
        }
    }
    If (IsEasyGenerator)
    {
        If (A_Index == 4)
        {
            TmpCuttingStr := SubStr(A_LoopReadLine, 4)
            Loop, Parse, TmpCuttingStr, `,
            {
                If (A_LoopField != "")
                {
                    TmpArrayOfCommands.Push(A_LoopField)
                }
            }
        }
        If (A_Index == 6)
        {
            TmpCuttingStr := SubStr(A_LoopReadLine, 4)
            Loop, Parse, TmpCuttingStr, `,
            {
                If (A_LoopField != "")
                {
                    TmpArrayOfParams.Push(A_LoopField)
                }
            }
        }
    }
}

If (IsEasyGenerator)
{
    ArrayOfCommands := TmpArrayOfCommands
    ArrayOfParams := TmpArrayOfParams
}

#Persistent
SetTimer, LoopTimer, 100
Goto, UpdateListBox
return

LoopTimer:
{
    GuiControlGet, ActivateShowMouse, EasyScriptGui:
    ; MsgBox, %ActivateShowMouse%
    If (ActivateShowMouse)
    {
        MouseGetPos, x_1, y_1, id_1, control_1
        ToolTip, X:%x_1% Y:%y_1%
        ShowToolTip := True
    } Else
    {
        If (ShowToolTip)
        {
            ShowToolTip := False
            ToolTip
        }
    }
    return
}

AddNewLine:
{
    GuiControlGet, CommandsListBox, EasyScriptGui:
    ; If ListBox Not Selected
    If (CommandsListBox == "")
    {
        ArrayOfCommands.Push("Время")
        ArrayOfParams.Push("1000")
    } Else
    {
        If (SubStr(CommandsListBox, 2, 1) == ",")
        {
            tmpIndex := SubStr(CommandsListBox, 1, 1)
        }
        Else
        {
            tmpIndex := SubStr(CommandsListBox, 1, 2)
        }
        ArrayOfCommands.InsertAt(tmpIndex, "Курсор")
        ArrayOfParams.InsertAt(tmpIndex, "100 100")
    }
    Goto, UpdateListBox
    return
}

DeleteSelectLine:
{
    GuiControlGet, CommandsListBox, EasyScriptGui:
    ; If ListBox Not Selected
    If (CommandsListBox == "")
    {
        ArrayOfCommands.Pop()
        ArrayOfParams.Pop()
    } Else
    {
        If (SubStr(CommandsListBox, 2, 1) == ",")
        {
            tmpIndex := SubStr(CommandsListBox, 1, 1)
        }
        Else
        {
            tmpIndex := SubStr(CommandsListBox, 1, 2)
        }
        ArrayOfCommands.RemoveAt(tmpIndex)
        ArrayOfParams.RemoveAt(tmpIndex)
    }
    Goto, UpdateListBox
    return
}

UpdateListBox:
{
    TmpStringListBox := ""
    For index, value in ArrayOfCommands
    {
        TmpStringListBox .= index
        TmpStringListBox .=", "
        TmpStringListBox .= value
        TmpStringListBox .=", "
        TmpStringListBox .= ArrayOfParams[index]
        TmpStringListBox .= "|"
    }
    ; MsgBox, % TmpStringListBox
    GuiControl, EasyScriptGui:, CommandsListBox, |
    GuiControl, EasyScriptGui:, CommandsListBox, %TmpStringListBox%
    return
}

SaveScript:
{
    TmpPath = %A_WorkingDir%\..\Scripts\%OutputScriptName%
    TmpStrCommand := ""
    TmpStrParam := ""
    For index, value in ArrayOfCommands
    {
        TmpStrCommand .= value
        TmpStrCommand .= ","
        TmpStrParam .= ArrayOfParams[index]
        TmpStrParam .= ","
    }
    file := FileOpen(TmpPath, "w")
    file.Write()
    file.Close()
    FileAppend,
        (
        `n ; EASY_MACRO
        `n ; %TmpStrCommand%
        `n ; %TmpStrParam%
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
        `nFileEncoding, CP65001
        `nCustomColor = FFFFFF  ; Can be any RGB color (it will be made transparent below).

        `nGui +LastFound +AlwaysOnTop -Caption +ToolWindow
        `nGui, Color, `%CustomColor`%
        `nGui, Font, s20  ; Set a large font size (32-point).
        `nGui, Add, Text, vMyText cLime, Воспроизведение...Ctrl+S для ОСТАНОВКИ
        `nWinSet, TransColor, `%CustomColor`% 150
        `nGui, Show, x100 y400 NoActivate
        `nloop:=1
        `nwhile(loop = 1)
        `n{
        ), %A_WorkingDir%\..\Scripts\%OutputScriptName%
    ; Marker string " ; Время, 1000"
    For index, value in ArrayOfCommands
    {
        tmpArrStr := ArrayOfParams[index]
        If (value == "Мышь")
        {
            If (ArrayOfParams[index] == "Левая")
            {
                FileAppend, 
                (
                `n ; Мышь, %tmpArrStr%
                `nsleep 4
                `nClick, down
                `nsleep 23
                `nClick, up
                `nsleep 15
                ), %A_WorkingDir%\..\Scripts\%OutputScriptName%
            } Else
            {
                If (ArrayOfParams[index] == "Правая")
                {
                    FileAppend, 
                    (
                    `n ; Мышь, %tmpArrStr%
                    `nsleep 4
                    `nClick, down Right
                    `nsleep 23
                    `nClick, up Right
                    `nsleep 15
                    ), %A_WorkingDir%\..\Scripts\%OutputScriptName%
                }
            }
        } Else
        {
            If (value == "Курсор")
            {
                tmpParamX := SubStr(ArrayOfParams[index], 1, InStr(ArrayOfParams[index], " ") - 1)
                tmpParamY := SubStr(ArrayOfParams[index], InStr(ArrayOfParams[index], " ") + 1)
                FileAppend,
                (
                `n ; Курсор, %tmpParamX% %tmpParamy%
                `nMouseMove, %tmpParamX%, %tmpParamy%, 2
                `nsleep 100
                ), %A_WorkingDir%\..\Scripts\%OutputScriptName%
            } Else 
            {
                If (value == "Клавиша")
                {
                    FileAppend, 
                    (
                    `n ; Клавиша, %tmpArrStr%
                    `nsleep 10
                    `nSend {%tmpArrStr% down}
                    `nsleep 23
                    `nSend {%tmpArrStr% up}
                    ), %A_WorkingDir%\..\Scripts\%OutputScriptName%
                } Else
                {
                    If (value == "Время")
                    {
                        FileAppend, 
                        (
                        `n ; Время, %tmpArrStr%
                        `nsleep %tmpArrStr%
                        ), %A_WorkingDir%\..\Scripts\%OutputScriptName%
                    }
                }
            }
        }
    }
    FileAppend, 
		(
		`n}
		`n^s:: ExitApp
		`nloop:=0
		`nExitApp
		`nreturn
		), %A_WorkingDir%\..\Scripts\%OutputScriptName%
    Goto, UpdateListBox
    return
}

ChangeLineCommand:
{
    GuiControlGet, CommandsListBox, EasyScriptGui:
    If (SubStr(CommandsListBox, 2, 1) == ",")
    {
        tmpIndex := SubStr(CommandsListBox, 1, 1)
    }
    Else
    {
        tmpIndex := SubStr(CommandsListBox, 1, 2)
    }
    If (ArrayOfCommands[tmpIndex] == "Мышь")
    {
        GuiControl, Choose, ComboBoxCommandChoose, 1
    } Else
    {
        If (ArrayOfCommands[tmpIndex] == "Курсор")
        {
            GuiControl, Choose, ComboBoxCommandChoose, 2
        } Else 
        {
            If (ArrayOfCommands[tmpIndex] == "Клавиша")
            {
                GuiControl, Choose, ComboBoxCommandChoose, 3
            } Else 
            {
                If (ArrayOfCommands[tmpIndex] == "Время")
                {
                    GuiControl, Choose, ComboBoxCommandChoose, 4
                }
            }
        }
    }
    GuiControl, EasyScriptGui:, ParamEdit, % ArrayOfParams[tmpIndex]
    return
}

ChangeCommandAttr:
{
    GuiControlGet, CommandsListBox, EasyScriptGui:
    GuiControlGet, ComboBoxCommandChoose, EasyScriptGui:
    GuiControlGet, ParamEdit, EasyScriptGui:
    If (SubStr(CommandsListBox, 2, 1) == ",")
    {
        tmpIndex := SubStr(CommandsListBox, 1, 1)
    }
    Else
    {
        tmpIndex := SubStr(CommandsListBox, 1, 2)
    }
    ArrayOfCommands[tmpIndex] := ComboBoxCommandChoose
    ArrayOfParams[tmpIndex] := ParamEdit
    ; Goto, UpdateListBox
    return
}
; MsgBox, Aboba

GuiClose:
ExitApp