{
    #Include, Lib\Socket.ahk
    #Include, Lib\JSON.ahk
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
    ; Socket variable
    global Server
    global DC_SERV := True
    global DC_CLI := False
    ; Initial Variables
    global InitGUI := False
    global IsToolTipShowing := False
    global IsHeroHelperShowing := False
    global IsNotifyShowing := False
    global IsCreepsWaveShowing := False
    global IsBossWaveShowing := False
    global PreviousMinute := 0
}

; Only Initialization
If (!InitGUI)
{
    ; Server connect info
    Server := new SocketTCP()
    Server.OnAccept := Func("OnAccept")
    IniRead, OutputPortBind, settings.ini, SystemSettings, port
    Server.Bind(["127.0.0.1", OutputPortBind])
    ; Help event 0x200 - if mouse event equal change window element call func Help
    OnMessage(0x200, "ShowHelp")
    Menu, Main_Submenu, Add, О программе, About_Menu
    Menu, GuiMain_MenuBar, Add, Меню, :Main_Submenu
    ; GuiMain Start
    Gui, Add, Checkbox, vActivateClickerPrompt, Включить подсказки
    Gui, Add, Checkbox, vActivateGlobal, Включить
    Gui, Add, Text,, Клавиша включения:
    IniRead, OutputKeyBind, settings.ini, UserSettings, activateclicker
    Gui, Add, Hotkey, vHotkeyActivateGlobal, %OutputKeyBind%

    ; Tab Section Start
        Gui, Add, Tab3, w200, Главная|Герой|Скрипты|Мидер

        ; Main
        Gui, Add, Text, cBlue, Автопокупка:
        Gui, Add, Checkbox, vActivateInActiveWindowBuy, В активном окне
        Gui, Add, Checkbox, vActivateInInactiveWindowBuy, Не в активном окне
        Gui, Add, Checkbox, vActivateHiddenGame gToggleTransparentWindow, Скрыть Dota 2
        Gui, Add, Text,, Золото:
        IniRead, OutputInt, settings.ini, UserSettings, goldlimit
        Gui, Add, Edit, r1 vGoldLimitEdit w100, %OutputInt%
        Gui, Add, Text,, Клавиша закупки:
        IniRead, OutputKeyBind, settings.ini, UserSettings, hotkeybuy
        Gui, Add, Hotkey, vHotkeyBuy, %OutputKeyBind%

        ; Hero
        Gui, Tab, Герой
        Gui, Add, Text, cGreen, Помошник по героям:
        Gui, Add, Checkbox, vActivateHeroHelper, Скиллы

        ; Scripts
        Gui, Tab, Скрипты
        Gui, Add, Text, cFuchsia, Список скриптов:
        Tmp_List := ""
        Loop, Files, Scripts\*.*, R
        {
            Tmp_List .= A_LoopFileShortName
            Tmp_List .= "|"
        }
        Gui, Add, ListBox, r10 vColorChoice, %Tmp_List%
        Gui, Add, Button,, Записать скрипт
        Gui, Add, Button, Default, Запустить скрипт

        ; Mider
        Gui, Tab, Мидер
        Gui, Add, Text, cOlive, Уведомления:
        Gui, Add, Checkbox, vActivateListWavesInfo, Список волн
        Gui, Add, Checkbox, vActivateCreepsWaveInfo, Только крипы
        Gui, Add, Checkbox, vActivateBassWaveInfo, Только босс
        Gui, Add, Checkbox, vActivateFreeTimeWaveInfo, Только Free Time
        Gui, Add, Checkbox, vActivateFasterCreepsTiming, Быстрые крипы
        Gui, Add, Checkbox, vActivateNotIfy1WaveInfo, 1 вышка
        Gui, Add, Checkbox, vActivateNotIfy2WavesInfo, 2 вышка
        Gui, Add, Checkbox, vActivateNotIfy3WavesInfo, 3 вышка
    ; Tab Section End

    ; GuiMain Continue
    Gui, Tab
    Gui, Add, Button, gSave_Click, Сохранить
    Gui, Add, Text, vGameTime, Время: 99:99
    Gui, Add, Text, vGoldText, Золото: 99999
    Gui, Menu, GuiMain_MenuBar
    Gui, Show, x200 y200 h440 w220, RDA-Clicker
    IniRead, OutputActivateHotkey, settings.ini, UserSettings, activateclicker
    Hotkey, %OutputActivateHotkey%, ToggleActivateClicker
    Server.Listen()
    InitGUI := True
    return
}

OnAccept(Server) {
	Sock := Server.Accept()
    ; Temporary text request
    TmpText := Sock.RecvText()
    ; 252 - start JSON quotes
    StrCopy := SubStr(TmpText, 252)
    ; Generate JSON GameData
    GameData := JSON.Load(StrCopy)
    TmpGold = % GameData.player.gold
    TmpMinutes = % GameData.map.clock_time
    TmpSeconds = % GameData.map.clock_time
    TmpGold := ("0" . TmpGold) , TmpGold += 0
    TmpMinutes := ("0" . TmpMinutes) , TmpMinutes += 0, TmpMinutes := TmpMinutes//60
    TmpSeconds := ("0" . TmpSeconds) , TmpSeconds += 0, TmpSeconds := Mod(TmpSeconds, 60)

    ; Setting GameTime and GoldText GUI
    GuiControl,, GameTime, Время: %TmpMinutes%:%TmpSeconds%
    GuiControl,, GoldText, Золото: %TmpGold%

    ; Getting all variable for main functionality
    GuiControlGet, ClickInActiveStatus,, ActivateInActiveWindowBuy
    GuiControlGet, ClickInInactiveStatus,, ActivateInInactiveWindowBuy
    GuiControlGet, ActivateGlobalStatus,, ActivateGlobal
    IniRead, OutputGoldLimitNum, settings.ini, UserSettings, goldlimit
    TmpGoldEdit := ("0" . OutputGoldLimitNum) , TmpGoldEdit += 0

    ; Debugging Main Functionality
    ; MsgBox, %ClickInActiveStatus% , %ActivateGlobalStatus% , %TmpGold%, %TmpGoldEdit%

    ; Main Tab Functionality
    If (ClickInActiveStatus And ActivateGlobalStatus And TmpGold > TmpGoldEdit)
    {
        IfWinActive, Dota 2
        {
            BuyInActiveWindow()
        }
    }
    If (ClickInInactiveStatus And ActivateGlobalStatus And TmpGold > TmpGoldEdit)
    {
        IfWinExist, Dota 2
        {
            BuyInInactiveWindow()
        }
    }

    ; Hero Tab Functionality NOT WORKING
    TmpHeroName = % GameData.hero.name
    ; MsgBox, %TmpHeroName%
    ; If TmpHeroName contains "npc_dota_hero_treant"
    IfEqual, TmpHeroName, "npc_dota_hero_treant"
    {
        TmpCooldown = % abilities.1.cooldown
        TmpCooldown := ("0" . TmpCooldown) , TmpCooldown += 0
        If (TmpCooldown == 0)
        {
            ShowHelpHeroMessage("Прожми дерево!")
            IsHeroHelperShowing := True
        }
    } Else
    IfEqual, TmpHeroName, "npc_dota_hero_tinker"
    {
        ShowHelpHeroMessage("Улучши башню!")
        IsHeroHelperShowing := True
    } Else
    If (IsHeroHelperShowing)
    {
        Gui, ability_helper: Cancel
        Gui, ability_helper: Hide
        Gui, ability_helper: Destroy
    }

    ; Mider Helper
    IfNotEqual, TmpMinutes, PreviousMinute
    {
        ; Show Waves
        
    }
    ; Main mid statuses
    GuiControlGet, CreepsWaveStatus,, ActivateCreepsWaveInfo
    GuiControlGet, BossWaveStatus,, ActivateBassWaveInfo
    GuiControlGet, FreeTimeWaveStatus,, ActivateFreeTimeWaveInfo
    ; Check ultra status
    GuiControlGet, FasterCreepsStatus,, ActivateFasterCreepsTiming
    ; 
    GuiControlGet, Notify1Status,, ActivateNotIfy1WavesInfo
    GuiControlGet, Notify2Status,, ActivateNotIfy2WavesInfo
    GuiControlGet, Notify3Status,, ActivateNotIfy3WavesInfo
    TmpMod5Minutes := Mod(TmpSeconds, 5)
    TmpMod6Minutes := Mod(TmpSeconds, 6)
    If (FasterCreepsStatus)
    {
        If (Notify1Status And TmpSeconds >= 10 And TmpSeconds <= 12 &&
        !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
        {
            ; Show Notify1
            ShowNotify1()
        }
        Else
        {
            If(IsNotifyShowing)
            {
                IsNotifyShowing := False
            }
        }
        If (Notify2Status And TmpSeconds >= 23 And TmpSeconds <= 25 &&
        !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
        {
            ; Show Notify2
            ShowNotify2()
        }
        Else
        {

        }
        If (Notify3Status And TmpSeconds >= 31 And TmpSeconds <= 33 &&
        !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
        {
            ; Show Notify3
            ShowNotify3()
        }
        Else
        {
            If(IsNotifyShowing)
            {
                IsNotifyShowing := False
            }
        }
        If (BossWaveStatus And TmpMod5Minutes == 0)
        {
            ; Show Boss Wave

        }
        Else
        {
            If(IsNotifyShowing)
            {
                IsNotifyShowing := False
            }
        }
        If (CreepsWaveStatus And TmpMod5Minutes != 0 && TmpMod6Minutes != 0)
        {
            ; Show Creeps Wave

        }
        Else
        {

        }
        If (FreeTimeWaveStatus And TmpMod5Minutes != 0 && TmpMod6Minutes == 0)
        {
            ; Show Free Time

        }
        Else
        {
            If(IsNotifyShowing)
            {
                IsNotifyShowing := False
            }
        }
    }
    Else
    {
        If (Notify1Status And TmpSeconds >= 17 And TmpSeconds <= 19 &&
        !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
        {
            ; Show Notify1
            ShowNotify1()
        } 
        Else
        {

        }
        If (Notify2Status And TmpSeconds >= 31 And TmpSeconds <= 33 &&
        !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
        {
            ; Show Notify2
            ShowNotify2()
        }
        Else
        {

        }
        If (Notify3Status And TmpSeconds >= 42 And TmpSeconds <= 44 &&
        !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
        {
            ; Show Notify3
            ShowNotify3()
        }
        Else
        {

        }
        If (BossWaveStatus And TmpMod5Minutes == 0)
        {
            ; Show Boss Wave

        }
        Else
        {

        }
        If (CreepsWaveStatus And TmpMod5Minutes != 0 && TmpMod6Minutes != 0)
        {
            ; Show Creeps Wave

        }
        Else
        {

        }
        If (FreeTimeWaveStatus And TmpMod5Minutes != 0 && TmpMod6Minutes == 0)
        {
            ; Show Free Time

        }
        Else
        {

        }
    }
    ; Disconnect Socket If DC_SERV is False
	If (DC_SERV)
		Sock.Disconnect()
    return
}

ShowNotify1()
{
    CustomColor = FFFFFF
    Gui, notify1: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify1: Color, %CustomColor%
    Gui, notify1: Font, s50
    Gui, notify1: Add, Text, cYellow, Башня 1
    WinSet, TransColor, %CustomColor% 200
    Gui, notify1: Show, xCenter y100 NoActivate
}

ShowNotify2()
{
    CustomColor = FFFFFF
    Gui, notify2: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify2: Color, %CustomColor%
    Gui, notify2: Font, s90
    Gui, notify2: Add, Text, cYellow, Башня 2
    WinSet, TransColor, %CustomColor% 200
    Gui, notify2: Show, xCenter y100 NoActivate
}

ShowNotify3()
{
    CustomColor = FFFFFF
    Gui, notify3: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify3: Color, %CustomColor%
    Gui, notify3: Font, s120
    Gui, notify3: Add, Text, cYellow, Башня 3
    WinSet, TransColor, %CustomColor% 200
    Gui, notify3: Show, xCenter y100 NoActivate
}

ShowCreepsWaveNotify()
{
    CustomColor = FFFFFF
    Gui, notify2: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify2: Color, %CustomColor%
    Gui, notify2: Font, s90
    Gui, notify2: Add, Text, cYellow, Крипы
    WinSet, TransColor, %CustomColor% 200
    Gui, notify2: Show, xCenter y100 NoActivate
}

ShowBossWaveNotify()
{
    CustomColor = FFFFFF
    Gui, notify2: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify2: Color, %CustomColor%
    Gui, notify2: Font, s90
    Gui, notify2: Add, Text, cYellow, Босс
    WinSet, TransColor, %CustomColor% 200
    Gui, notify2: Show, xCenter y100 NoActivate
}

ShowFreetimeWaveNotify()
{
    CustomColor = FFFFFF
    Gui, notify2: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify2: Color, %CustomColor%
    Gui, notify2: Font, s90
    Gui, notify2: Add, Text, cYellow, Freetime
    WinSet, TransColor, %CustomColor% 200
    Gui, notify2: Show, xCenter y100 NoActivate
}

ShowHelpHeroMessage(message)
{
    CustomColor = FFFFFF
    Gui, ability_helper: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, ability_helper: Color, %CustomColor%
    Gui, ability_helper: Font, s20
    Gui, ability_helper: Add, Text, cYellow, %message%
    WinSet, TransColor, %CustomColor% 255
    Gui, ability_helper: Show, xCenter y600 NoActivate
}

; Toggle Activate Clicker
ToggleActivateClicker:
{
    GuiControlGet, ActivateGlobalStatus,, ActivateGlobal
    If (ActivateGlobalStatus)
    {
        GuiControl,, ActivateGlobal, 0
    } else {
        GuiControl,, ActivateGlobal, 1
    }
    return
}
; Toggle Transparent Game Window
ToggleTransparentWindow:
{
    GuiControlGet, TransparentStatus,, ActivateHiddenGame
    If (TransparentStatus)
    {
        IfWinExist, Dota 2
        {
            WinSet, Transparent, 0
        }
    } else {
        IfWinExist, Dota 2
        {
            ; Off and 255 break server
            WinSet, Transparent, 250
        }
    }
    return
}

; Buy in Active Window
BuyInActiveWindow()     
{
    IfWinActive, Dota 2
    {
        SetKeyDelay 60
        IniRead, OutputInt, settings.ini, UserSettings, hotkeybuy
        Send, {Alt up}
        Send, {%OutputInt% down}
        Send, {%OutputInt% up}
        return
    }
}

; Buy in Inactive Window
BuyInInactiveWindow()
{
    SetKeyDelay 60
    IfWinExist, Dota 2
    {
        IniRead, OutputInt, settings.ini, UserSettings, hotkeybuy
        WinActivate ; Use the window found by IfWinExist.
        Send, {Alt up}
        Send, {%OutputInt% down}
        Send, {%OutputInt% up}
        WinMinimize
    }
    return
}

; Add in menu bar About Menu
About_Menu:
{
    Gui, Gui_AboutProgram: Add, Text,, Данная программа полезна только`nдля кастомки RDA.`nСоздатель @Koljisto#3478 (Discord)
    Gui, Gui_AboutProgram: Add, Link,, Для донатов (на пиво) <a href="https://new.donatepay.ru/@1009625">сюда</a>
    Gui, Gui_AboutProgram: Show, x200 y200, RDA-Clicker
    return
}

; If help checkbox is active
ShowHelp(wParam, lParam, Msg)
{
    GuiControlGet, PromptCheckedStatus,, ActivateClickerPrompt
    If (PromptCheckedStatus)
    {
        If (!IsToolTipShowing)
        {
            IsToolTipShowing := True
        }
        MouseGetPos,,,, OutputVarControl
        IfEqual, OutputVarControl, Button1
            Help := "Нажмите сюда для отключения подсказок"
        else IfEqual, OutputVarControl, Button2
            Help := "Включает функционал всего кликера"
        else IfEqual, OutputVarControl, Button3
            Help := "Будет происходить закупка`nтолько если окно активно"
        else IfEqual, OutputVarControl, Button4
            Help := "Будет происходить закупка`nтолько если окно не активно"
        else IfEqual, OutputVarControl, Button5
            Help := "Скрывает окно игры. Переключи`nперед закрытием кликера"
        else IfEqual, OutputVarControl, Button6
            Help := "Выводить уведомление, что`nскилл откатился (Treant и Tinker)"
        else IfEqual, OutputVarControl, Button7
            Help := "Записать в данный скрипт`nновый функционал"
        else IfEqual, OutputVarControl, Button8
            Help := "Запустить выбранный скрипт"
        else IfEqual, OutputVarControl, Button9
            Help := "Выводит информацию о последующих`nволнах (6 волн)"
        else IfEqual, OutputVarControl, Button10
            Help := "Выводит на экран, что идут крипы"
        else IfEqual, OutputVarControl, Button11
            Help := "Выводит на экран, что идёт босс"
        else IfEqual, OutputVarControl, Button12
            Help := "Выводит на экран, что сейчас free time"
        else IfEqual, OutputVarControl, Button13
            Help := "Включать на сложности`nУльтра"
        else IfEqual, OutputVarControl, Button14
            Help := "Сообщает, что крипы уже у первой`nбашни"
        else IfEqual, OutputVarControl, Button15
            Help := "Сообщает, что крипы уже у второй`nбашни"
        else IfEqual, OutputVarControl, Button16
            Help := "Сообщает, что крипы уже у третьей`nбашни"
        else IfEqual, OutputVarControl, Button17
            Help := "Сохраняет ваши изменения в ini файл"
        else IfEqual, OutputVarControl, Edit1
            Help := "Количество золота для срабатывания`nзакупки кликером"
        else IfEqual, OutputVarControl, ListBox1
            Help := "Здесь нужно выбрать скрипт для`nисполнения"
        else IfEqual, OutputVarControl, #327701
            Help := "Переключайте разделы для просмотра`nфункционала"
        else IfEqual, OutputVarControl, Static8
            Help := "Отображает время в катке"
        else IfEqual, OutputVarControl, Static9
            Help := "Отображает золото игрока"
        else IfEqual, OutputVarControl, msctls_hotkey321
            Help := "Назначьте клавишу для включения`nфункционала просто нажмите её`nили комбинацию"
        else IfEqual, OutputVarControl, msctls_hotkey322
            Help := "Назначьте клавишу для закупки`nпросто нажмите её или комбинацию"
        else
            Help:= "Наведите на элемент, а я`nрасскажу что он делает"
        ToolTip, % Help
    } Else {
        If (IsToolTipShowing)
        {
            IsToolTipShowing := False
            ToolTip
        }
    }
}

; Convert Hotkey code to Text for text fields
HotkeyToText(String)
{
    TmpString := ""
    TmpCounter := 1
    FindShIft := "+"
    FindCtrl := "^"
    FindAlt := "!"
    IfInString, String, %FindCtrl%
    {
        TmpString .= "Ctrl + "
        TmpCounter++
    }
    IfInString, String, %FindShIft%
    {
        TmpString .= "ShIft + "
        TmpCounter++
    }
    IfInString, String, %FindAlt%
    {
        TmpString .= "Alt + "
        TmpCounter++
    }
    TmpString .= SubStr(String, TmpCounter)
    return TmpString
}

; Save click event
Save_Click:
{
    ; Save Activate Key
    IniRead, OutputActivateHotkeyReaded, settings.ini, UserSettings, activateclicker
    Hotkey, %OutputActivateHotkeyReaded%, Off
    GuiControlGet, OutputActivateHotkey,, HotkeyActivateGlobal
    IniWrite, %OutputActivateHotkey%, settings.ini, UserSettings, activateclicker
    Hotkey, %OutputActivateHotkey%, ToggleActivateClicker
    TmpString := HotkeyToText(OutputActivateHotkey)
    IniWrite, %TmpString%, settings.ini, UserSettings, activateclickertext
    
    ; Save Buy key
    GuiControlGet, OutputBuyHotkey,, HotkeyBuy
    IniWrite, %OutputBuyHotkey%, settings.ini, UserSettings, hotkeybuy
    TmpString := HotkeyToText(OutputBuyHotkey)
    IniWrite, %TmpString%, settings.ini, UserSettings, hotkeybuytext
    ; Save gold limit
    GuiControlGet, OutputBuyHotkey,, GoldLimitEdit
    IniWrite, %OutputBuyHotkey%, settings.ini, UserSettings, goldlimit
    return
}