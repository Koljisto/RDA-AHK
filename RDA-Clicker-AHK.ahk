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
    global IsToolTipShowing := False
    global IsHeroHelperShowing := False
    global IsNotifyShowing := False
    global IsCreepsWaveShowing := False
    global IsBossWaveShowing := False
    global IsFreeTimeWaveShowing := False
    global IsListOfWavesShowing := False
    global IsCanAutobuy := False
    global PreviousMinute := 0
    FileEncoding, CP65001
    IniRead, OutputDelay, settings.ini, UserSettings, scriptdelay
}

InitGUI:
{
    ; Help event 0x200 - if mouse event equal change window element call func Help
    OnMessage(0x200, "ShowHelp")
    Menu, Main_Submenu, Add, О программе, About_Menu
    Menu, GuiMain_MenuBar, Add, Меню, :Main_Submenu
    Gui, MainGui: New
    Gui, Menu, GuiMain_MenuBar
    ; GuiMain Start
    Gui, Add, Checkbox, x12 y9 w140 h20 vActivateClickerPrompt, Включить подсказки
    Gui, Add, Checkbox, x12 y29 w140 h20 vActivateGlobal, Включить
    Gui, Add, Button, x152 y9 w60 h20 gCreateConfig, Конфиг
    Gui, Add, Text, x12 y49 w250 h20, Клавиша включения:
    IniRead, OutputKeyBind, settings.ini, UserSettings, activateclicker
    Gui, Add, Hotkey, x12 y69 w250 h20 vHotkeyActivateGlobal, %OutputKeyBind%

    ; Tab Section Start
        Gui, Add, Tab3, x12 y89 w250 h200 , Главная|Герой|Скрипты|Мидер

        ; Main
        Gui, Add, Text, x22 y119 w120 h20 cBlue, Автопокупка:
        Gui, Add, Checkbox, x22 y139 w120 h20 vActivateInActiveWindowBuy, В активном окне
        Gui, Add, Checkbox, x22 y159 w120 h20 vActivateInInactiveWindowBuy, Не в активном окне
        Gui, Add, Checkbox, x22 y179 w120 h20 vActivateHiddenGame gToggleTransparentWindow, Скрыть Dota 2
        Gui, Add, Text, x22 y199 w120 h20, Золото:
        IniRead, OutputInt, settings.ini, UserSettings, goldlimit
        Gui, Add, Edit, r1 vGoldLimitEdit x22 y219 w120 h20 , %OutputInt%
        Gui, Add, Text, x22 y239 w120 h20 , Клавиша закупки:
        IniRead, OutputKeyBind, settings.ini, UserSettings, hotkeybuy
        Gui, Add, Hotkey, x22 y259 w120 h20 vHotkeyBuy, %OutputKeyBind%


        ; Hero
        Gui, Tab, Герой
        Gui, Add, Text, x22 y119 w120 h20 cGreen, Помошник по героям:
        Gui, Add, Checkbox, x22 y139 w120 h20 vActivateHeroHelper, Скиллы
        Gui, Add, Checkbox, x22 y159 w120 h20 vActivateHeroBuildHelper, Билд

        ; Scripts
        Gui, Tab, Скрипты
        Gui, Add, Text, x22 y119 w100 h20 cFuchsia, Список скриптов:
        Tmp_List := ""
        Loop, Files, Scripts\*.*, R
        {
            Tmp_List .= A_LoopFileShortName
            Tmp_List .= "|"
        }
        Gui, Add, ListBox, x22 y139 w80 h110 r10 vScriptsListBox, %Tmp_List%
        Gui, Add, Button, x112 y139 w140 h20 gRecordScript, Записать скрипт
        Gui, Add, Button, x112 y159 w140 h20 gEasyRecordScript, Записать скрипт (Легко)
        Gui, Add, Button, x112 y179 w140 h20 gAddScript, Добавить скрипт
        Gui, Add, Button, x112 y199 w140 h20 gDeleteScript, Удалить скрипт
        Gui, Add, Button, x112 y229 w140 h20 gRunScript Default, Запустить скрипт

        ; Mider
        Gui, Tab, Мидер
        Gui, Add, Text, x22 y119 w110 h20 cOlive, Уведомления:
        Gui, Add, Checkbox, x22 y139 w110 h20 vActivateListWavesInfo, Список волн
        Gui, Add, Checkbox, x22 y159 w110 h20 vActivateCreepsWaveInfo, Только крипы
        Gui, Add, Checkbox, x22 y179 w110 h20 vActivateBassWaveInfo, Только босс
        Gui, Add, Checkbox, x22 y199 w110 h20 vActivateFreeTimeWaveInfo, Только Free Time
        Gui, Add, Checkbox, x142 y139 w110 h20 vActivateFasterCreepsTiming, Быстрые крипы
        Gui, Add, Checkbox, x142 y159 w110 h20 vActivateNotify1WaveInfo, 1 вышка
        Gui, Add, Checkbox, x142 y179 w110 h20 vActivateNotify2WaveInfo, 2 вышка
        Gui, Add, Checkbox, x142 y199 w110 h20 vActivateNotify3WaveInfo, 3 вышка
    ; Tab Section End


    ; GuiMain Continue
    Gui, Tab
    Gui, Add, Button, x22 y299 w100 h20 gSaveClick, Сохранить
    Gui, Add, Text, x22 y329 w100 h20 vGameTime , Время: 99:99
    Gui, Add, Text, x22 y349 w100 h20 vGoldText , Золото: 99999
    Gui, Show, x127 y87 h370 w278, RDA-Clicker
    IniRead, OutputActivateHotkey, settings.ini, UserSettings, activateclicker
    Hotkey, %OutputActivateHotkey%, ToggleActivateClicker
    Menu, Tray, Add,,
    Menu, Tray, Add, Открыть кликер, TrayLogic
    Menu, Tray, Icon, SystemScripts/clicker.ico
    IniRead, OutputIsFirstTime, settings.ini, SystemSettings, isfirsttime
    IniRead, OutputGameFolder, settings.ini, SystemSettings, gamefolder
    If (%OutputIsFirstTime% Or OutputGameFolder=="")
    {
        Goto, CreateConfig
    }
    Else
    {
        IfNotExist, %OutputGameFolder%/game/dota/cfg/gamestate_integration/gamestate_integration_test.cfg
        {
            IfExist, SystemScripts/gamestate_integration_test.cfg
            {
                IfExist, %OutputGameFolder%/game/dota/cfg/gamestate_integration/
                {
                    FileCopy, SystemScripts/gamestate_integration_test.cfg, %OutputGameFolder%/game/dota/cfg/gamestate_integration/gamestate_integration_test.cfg, 1
                }
                Else
                {
                    FileCreateDir, %OutputGameFolder%/game/dota/cfg/gamestate_integration/
                    FileCopy, SystemScripts/gamestate_integration_test.cfg, %OutputGameFolder%/game/dota/cfg/gamestate_integration/gamestate_integration_test.cfg, 1
                }
            }
            Else
            {
                MsgBox, Не был найден дефолтный конфиг.
            }
            MsgBox, Конфиг не был найден в игре. Был загружен обычный из SystemScripts
        }
    }
}

InitConnect:
{
    ; Server connect info
    Server.Disconnect()
    Server := new SocketTCP()
    Server.OnAccept := Func("OnAccept")
    IniRead, OutputPortBind, settings.ini, SystemSettings, port
    Server.Bind(["127.0.0.1", OutputPortBind])
    Server.Listen()
    return
}

TrayLogic:
{
    Gui, MainGui:Show
    return
}

OnAccept(Server) {
    try
    {
        Sock := Server.Accept()
        ; Temporary text request
        TmpText := Sock.RecvText()
        Sock.SendText("HTTP/2.1 200 OK`nContent-Type: text/html")
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
        ; Dropping incorrect data
        If (TmpSeconds == 0)
        {
            return
        }
        ; Setting GameTime and GoldText GUI
        If (TmpMinutes < 10 And TmpSeconds < 10)
        {
            GuiControl, MainGui: , GameTime, Время: 0%TmpMinutes%:0%TmpSeconds%
        } Else
        {
            If (TmpMinutes < 10)
            {
                GuiControl, MainGui: , GameTime, Время: 0%TmpMinutes%:%TmpSeconds%
            } Else
            {
                If (TmpSeconds < 10)
                {
                    GuiControl, MainGui: , GameTime, Время: %TmpMinutes%:0%TmpSeconds%
                } Else
                {
                    GuiControl, MainGui: , GameTime, Время: %TmpMinutes%:%TmpSeconds%
                }
            }
        }
        ; GuiControl,, GameTime, Время: %TmpMinutes%:%TmpSeconds%
        GuiControl, MainGui:, GoldText, Золото: %TmpGold%

        ; Getting all variable for main functionality
        GuiControlGet, ActivateInActiveWindowBuy, MainGui:
        GuiControlGet, ActivateInInactiveWindowBuy, MainGui:
        GuiControlGet, ActivateGlobal, MainGui:
        GuiControlGet, ActivateHeroHelper, MainGui:
        IniRead, OutputGoldLimitNum, settings.ini, UserSettings, goldlimit
        TmpGoldEdit := ("0" . OutputGoldLimitNum) , TmpGoldEdit += 0

        ; Debugging Main Functionality
        ; MsgBox, %ActivateInActiveWindowBuy% , %ActivateGlobal% , %TmpGold%, %TmpGoldEdit%

        ; Main Tab Functionality
        If (ActivateInActiveWindowBuy And ActivateGlobal And TmpGold > TmpGoldEdit And !IsCanAutobuy)
        {
            IfWinActive, Dota 2
            {
                IsCanAutobuy := True
                BuyInActiveWindow()
            }
        }
        If (ActivateInInactiveWindowBuy And ActivateGlobal And TmpGold > TmpGoldEdit And !IsCanAutobuy)
        {
            IfWinExist, Dota 2
            {
                IsCanAutobuy := True
                BuyInInactiveWindow()
            }
        }
        If (ActivateHeroHelper)
        {
            ; Hero Tab Functionality
            TmpHeroName := GameData.hero.name
            IfEqual, TmpHeroName, npc_dota_hero_treant
            {
                TmpCooldown = % GameData.abilities.ability1.cooldown
                TmpCooldown := ("0" . TmpCooldown) , TmpCooldown += 0
                If (TmpCooldown == 0)
                {
                    ShowHelpHeroMessage("Прожми дерево!")
                    IsHeroHelperShowing := True
                } Else 
                {
                    If (IsHeroHelperShowing)
                    {
                        Gui, ability_helper: Cancel
                        Gui, ability_helper: Hide
                        Gui, ability_helper: Destroy
                        IsHeroHelperShowing := False
                    }
                }
            } Else
            {
                IfEqual, TmpHeroName, npc_dota_hero_tinker
                {
                    TmpCooldown = % GameData.abilities.ability4.cooldown
                    TmpCooldown := ("0" . TmpCooldown) , TmpCooldown += 0
                    If (TmpCooldown == 0)
                    {
                        ShowHelpHeroMessage("Улучши башню!")
                        IsHeroHelperShowing := True
                    } Else
                    {
                        If (IsHeroHelperShowing)
                        {
                            Gui, ability_helper: Cancel
                            Gui, ability_helper: Hide
                            Gui, ability_helper: Destroy
                            IsHeroHelperShowing := False
                        }
                    }
                } Else
                {
                    If (IsHeroHelperShowing)
                    {
                        Gui, ability_helper: Cancel
                        Gui, ability_helper: Hide
                        Gui, ability_helper: Destroy
                        IsHeroHelperShowing := False
                    }
                }
            }
        } Else
        {
            If (IsHeroHelperShowing)
            {
                Gui, ability_helper: Cancel
                Gui, ability_helper: Hide
                Gui, ability_helper: Destroy
                IsHeroHelperShowing := False
            }
        }
        ; Main mid statuses
        GuiControlGet, ActivateListWavesInfo, MainGui:
        GuiControlGet, ActivateCreepsWaveInfo, MainGui:
        GuiControlGet, ActivateBassWaveInfo, MainGui:
        GuiControlGet, ActivateFreeTimeWaveInfo, MainGui:
        ; Check ultra status
        GuiControlGet, ActivateFasterCreepsTiming, MainGui:
        ; 
        GuiControlGet, ActivateNotify1WaveInfo, MainGui:
        GuiControlGet, ActivateNotify2WaveInfo, MainGui:
        GuiControlGet, ActivateNotify3WaveInfo, MainGui:
        TmpMod5Minutes := Mod(TmpMinutes, 5)
        TmpMod6Minutes := Mod(TmpMinutes, 6)
        If (TmpMinutes != PreviousMinute)
        {
            Gui, list_of_waves_notify: Cancel
            Gui, list_of_waves_notify: Hide
            Gui, list_of_waves_notify: Destroy
            PreviousMinute = %TmpMinutes%
            If (IsListOfWavesShowing)
            {
                ShowListOfWavesNotify(GenerateListOfWavesString(TmpMinutes))
            }
        }
        ; Mider Helper
        If (ActivateListWavesInfo)
        {
            ; Show Waves
            If (!IsListOfWavesShowing)
            {
                IsListOfWavesShowing := True
                ShowListOfWavesNotify(GenerateListOfWavesString(TmpMinutes))
            }
        } Else
        {
            If (IsListOfWavesShowing)
            {
                IsListOfWavesShowing := False
                Gui, list_of_waves_notify: Cancel
                Gui, list_of_waves_notify: Hide
                Gui, list_of_waves_notify: Destroy
            }
        }
        If (ActivateFasterCreepsTiming)
        {
            If (ActivateNotify1WaveInfo And TmpSeconds >= 10 And TmpSeconds <= 12 &&
            !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
            {
                ; Show Notify1
                If (!IsNotifyShowing)
                {
                    IsNotifyShowing := True
                    ShowNotify("Башня 1", 50)
                }
            }
            Else
            {

                If (ActivateNotify2WaveInfo And TmpSeconds >= 23 And TmpSeconds <= 25 &&
                !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
                {
                    ; Show Notify2
                    If (!IsNotifyShowing)
                    {
                        IsNotifyShowing := True
                        ShowNotify("Башня 2", 90)
                    }
                }
                Else
                {
                    If (ActivateNotify3WaveInfo And TmpSeconds >= 31 And TmpSeconds <= 33 &&
                    !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
                    {
                        If (!IsNotifyShowing)
                        {
                            IsNotifyShowing := True
                            ShowNotify("Башня 3", 120)
                        }
                    }
                    Else
                    {
                        If(IsNotifyShowing)
                        {
                            IsNotifyShowing := False
                            Gui, notify: Cancel
                            Gui, notify: Hide
                            Gui, notify: Destroy
                        }
                    }
                }
            }
        }
        Else
        {
            If (ActivateNotify1WaveInfo And TmpSeconds >= 20 And TmpSeconds <= 22 &&
            !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
            {
                ; Show Notify1
                If (!IsNotifyShowing)
                {
                    IsNotifyShowing := True
                    ShowNotify("Башня 1", 50)
                }
            }
            Else
            {
                If (ActivateNotify2WaveInfo And TmpSeconds >= 27 And TmpSeconds <= 29 &&
                !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
                {
                    ; Show Notify2
                    If (!IsNotifyShowing)
                    {
                        IsNotifyShowing := True
                        ShowNotify("Башня 2", 90)
                    }
                }
                Else
                {
                    If (ActivateNotify3WaveInfo And TmpSeconds >= 39 And TmpSeconds <= 41 &&
                    !(TmpMod5Minutes != 0 && TmpMod6Minutes == 0))
                    {
                        ; Show Notify3
                        If (!IsNotifyShowing)
                        {
                            IsNotifyShowing := True
                            ShowNotify("Башня 3", 120)
                        }
                    }
                    Else
                    {
                        If (IsNotifyShowing)
                        {
                            IsNotifyShowing := False
                            Gui, notify: Cancel
                            Gui, notify: Hide
                            Gui, notify: Destroy
                        }
                    }
                }
            }
        }
        If (ActivateBassWaveInfo And TmpMod5Minutes == 0)
        {
            ; Show Boss Wave
            If (!IsBossWaveShowing)
            {
                IsBossWaveShowing := True
                ShowBossWaveNotify()
            }
        }
        Else
        {
            If (IsBossWaveShowing)
            {
                IsBossWaveShowing := False
                Gui, boss_wave_notify: Cancel
                Gui, boss_wave_notify: Hide
                Gui, boss_wave_notify: Destroy
            }
        }
        If (ActivateCreepsWaveInfo And TmpMod5Minutes != 0 && TmpMod6Minutes != 0)
        {
            ; Show Creeps Wave
            If (!IsCreepsWaveShowing)
            {
                IsCreepsWaveShowing := True
                ShowCreepsWaveNotify()
            }
        }
        Else
        {
            If (IsCreepsWaveShowing)
            {
                IsCreepsWaveShowing := False
                Gui, creeps_wave_notify: Cancel
                Gui, creeps_wave_notify: Hide
                Gui, creeps_wave_notify: Destroy
            }
        }
        If (ActivateFreeTimeWaveInfo And TmpMod5Minutes != 0 && TmpMod6Minutes == 0)
        {
            ; Show Free Time
            If (!IsFreeTimeWaveShowing)
            {
                IsFreeTimeWaveShowing := True
                ShowFreetimeWaveNotify()
            }
        }
        Else
        {
            If (IsFreeTimeWaveShowing)
            {
                IsFreeTimeWaveShowing := False
                Gui, freetime_wave_notify: Cancel
                Gui, freetime_wave_notify: Hide
                Gui, freetime_wave_notify: Destroy
            }
        }
        ; Disconnect Socket If DC_SERV is True
        If (DC_SERV)
            Sock.Disconnect()
        Sleep, %OutputDelay%
    }
    catch e
    {
        ; Server connect info
        Server.Disconnect()
        Server := new SocketTCP()
        Server.OnAccept := Func("OnAccept")
        IniRead, OutputPortBind, settings.ini, SystemSettings, port
        Server.Bind(["127.0.0.1", OutputPortBind])
        Server.Listen()
    }
    return
}

ShowNotify(message, size)
{
    CustomColor = FFFFFF
    Gui, notify: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, notify: Color, %CustomColor%
    Gui, notify: Font, s%size%
    Gui, notify: Add, Text, cYellow, %message%
    WinSet, TransColor, %CustomColor% 200
    Gui, notify: Show, xCenter y100 NoActivate
    return
}

ShowCreepsWaveNotify()
{
    CustomColor = FFFFFF
    Gui, creeps_wave_notify: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, creeps_wave_notify: Color, %CustomColor%
    Gui, creeps_wave_notify: Font, s40
    Gui, creeps_wave_notify: Add, Text, cYellow, Крипы
    WinSet, TransColor, %CustomColor% 150
    Gui, creeps_wave_notify: Show, x0 yCenter NoActivate
    return
}

ShowBossWaveNotify()
{
    CustomColor = FFFFFF
    Gui, boss_wave_notify: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, boss_wave_notify: Color, %CustomColor%
    Gui, boss_wave_notify: Font, s40
    Gui, boss_wave_notify: Add, Text, cRed, Босс
    WinSet, TransColor, %CustomColor% 150
    Gui, boss_wave_notify: Show, x0 yCenter NoActivate
    return
}

ShowFreetimeWaveNotify()
{
    CustomColor = FFFFFF
    Gui, freetime_wave_notify: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, freetime_wave_notify: Color, %CustomColor%
    Gui, freetime_wave_notify: Font, s40
    Gui, freetime_wave_notify: Add, Text, cGreen, Freetime
    WinSet, TransColor, %CustomColor% 150
    Gui, freetime_wave_notify: Show, x0 yCenter NoActivate
    return
}

ShowListOfWavesNotify(message)
{
    CustomColor = FFFFFF
    Gui, list_of_waves_notify: +LastFound +AlwaysOnTop -Caption +ToolWindow
    Gui, list_of_waves_notify: Color, %CustomColor%
    Gui, list_of_waves_notify: Font, s30
    Gui, list_of_waves_notify: Add, Text, cGreen, %message%
    WinSet, TransColor, %CustomColor% 150
    Gui, list_of_waves_notify: Show, x50 y50 NoActivate
    return
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
    return
}

; Toggle Activate Clicker
ToggleActivateClicker:
{
    GuiControlGet, ActivateGlobal, MainGui:
    If (ActivateGlobal)
    {
        GuiControl, MainGui:, ActivateGlobal, 0
    } else {
        GuiControl, MainGui:, ActivateGlobal, 1
    }
    return
}
; Toggle Transparent Game Window
ToggleTransparentWindow:
{
    GuiControlGet, ActivateHiddenGame, MainGui:
    If (ActivateHiddenGame)
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
        If (IsCanAutobuy)
        {
            ; SetKeyDelay 400
            IniRead, OutputInt, settings.ini, UserSettings, hotkeybuy
            Send, {Alt up}
            Send, {%OutputInt% down}
            Send, {%OutputInt% up}
            Sleep, 500
            IsCanAutobuy := False
        }
    }
    return
}

; Buy in Inactive Window
BuyInInactiveWindow()
{
    IfWinExist, Dota 2
    {
        If (IsCanAutobuy)
        {
            ; SetKeyDelay 400
            IniRead, OutputInt, settings.ini, UserSettings, hotkeybuy
            WinActivate ; Use the window found by IfWinExist.
            Send, {Alt up}
            Send, {%OutputInt% down}
            Send, {%OutputInt% up}
            WinMinimize
            Sleep, 500
            IsCanAutobuy := False
        }
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
    GuiControlGet, ActivateClickerPrompt, MainGui:
    If (ActivateClickerPrompt)
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
            Help := "Переместить конфиг из папки`nSystemScripts в папку с игрой."
        else IfEqual, OutputVarControl, Button4
            Help := "Будет происходить закупка`nтолько если окно активно"
        else IfEqual, OutputVarControl, Button5
            Help := "Будет происходить закупка`nтолько если окно не активно"
        else IfEqual, OutputVarControl, Button6
            Help := "Скрывает окно игры. Переключи`nперед закрытием кликера"
        else IfEqual, OutputVarControl, Button7
            Help := "Выводить уведомление, что`nскилл откатился (Treant и Tinker)"
        else IfEqual, OutputVarControl, Button8
            Help := "Вывести билд для героя"
        else IfEqual, OutputVarControl, Button9
            Help := "Записать в данный скрипт`nновый функционал"
        else IfEqual, OutputVarControl, Button10
            Help := "Записать в данный скрипт`nновый функционал(упрощенный)"
        else IfEqual, OutputVarControl, Button11
            Help := "Добавить новый скрипт"
        else IfEqual, OutputVarControl, Button12
            Help := "Удалить выбранный скрипт"
        else IfEqual, OutputVarControl, Button13
            Help := "Запустить выбранный скрипт"
        else IfEqual, OutputVarControl, Button14
            Help := "Выводит информацию о последующих`nволнах (6 волн)"
        else IfEqual, OutputVarControl, Button15
            Help := "Выводит на экран, что идут крипы"
        else IfEqual, OutputVarControl, Button16
            Help := "Выводит на экран, что идёт босс"
        else IfEqual, OutputVarControl, Button17
            Help := "Выводит на экран, что сейчас free time"
        else IfEqual, OutputVarControl, Button18
            Help := "Включать на сложности`nУльтра"
        else IfEqual, OutputVarControl, Button19
            Help := "Сообщает, что крипы уже у первой`nбашни"
        else IfEqual, OutputVarControl, Button20
            Help := "Сообщает, что крипы уже у второй`nбашни"
        else IfEqual, OutputVarControl, Button21
            Help := "Сообщает, что крипы уже у третьей`nбашни"
        else IfEqual, OutputVarControl, Button22
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
    return
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

GenerateListOfWavesString(IntMinutes)
{
    TmpStringListOfWaves := ""
    Loop, 6
    {
        TmpStringIndex := % A_Index-1
        FinalIndex := TmpStringIndex + IntMinutes
        TmpMod5FinalIndex := Mod(FinalIndex, 5)
        TmpMod6FinalIndex := Mod(FinalIndex, 6)
        If (TmpMod5FinalIndex == 0)
        {
            TmpStringListOfWaves .= FinalIndex
            TmpStringListOfWaves .= " - Босс`n"
        } Else
        {
            If (TmpMod6FinalIndex == 0)
            {
                TmpStringListOfWaves .= FinalIndex
                TmpStringListOfWaves .= " - Freetime`n"
            } Else 
            {
                TmpStringListOfWaves .= FinalIndex
                TmpStringListOfWaves .= " - Крипы`n"
            }
        }
    }
    return TmpStringListOfWaves
}

; Save click event
SaveClick:
{
    ; Save Activate Key
    IniRead, OutputActivateHotkeyReaded, settings.ini, UserSettings, activateclicker
    Hotkey, %OutputActivateHotkeyReaded%, Off
    GuiControlGet, HotkeyActivateGlobal, MainGui:
    IniWrite, %HotkeyActivateGlobal%, settings.ini, UserSettings, activateclicker
    Hotkey, %HotkeyActivateGlobal%, ToggleActivateClicker
    TmpString := HotkeyToText(HotkeyActivateGlobal)
    IniWrite, %TmpString%, settings.ini, UserSettings, activateclickertext
    
    ; Save Buy key
    GuiControlGet, HotkeyBuy, MainGui:
    IniWrite, %HotkeyBuy%, settings.ini, UserSettings, hotkeybuy
    TmpString := HotkeyToText(HotkeyBuy)
    IniWrite, %TmpString%, settings.ini, UserSettings, hotkeybuytext
    ; Save gold limit
    GuiControlGet, GoldLimitEdit, MainGui:
    IniWrite, %GoldLimitEdit%, settings.ini, UserSettings, goldlimit
    return
}

RecordScript:
{
    ; Open Record GUI
    GuiControlGet, ScriptsListBox, MainGui:
    Loop, Parse, ScriptsListBox, |
    {
        IniWrite, %A_LoopField%, settings.ini, Scripts, scriptname
    }
    Run, %A_WorkingDir%\SystemScripts\macro_recorder.ahk
    return
}

EasyRecordScript:
{
    ; Open Easy Record GUI
    GuiControlGet, ScriptsListBox, MainGui:
    Loop, Parse, ScriptsListBox, |
    {
        IniWrite, %A_LoopField%, settings.ini, Scripts, scriptname
    }
    Run, %A_WorkingDir%\SystemScripts\easy_macro_recorder.ahk
    return
}

AddScript:
{
    InputBox, OutputFileName, Создание скрипта, Введите название скрипта:
    If (!ErrorLevel)
    {
        FileAppend,, %A_WorkingDir%\Scripts\%OutputFileName%.ahk
    }
    Tmp_List := ""
    Loop, Files, Scripts\*.*, R
    {
        Tmp_List .= A_LoopFileShortName
        Tmp_List .= "|"
    }
    GuiControl,, ScriptsListBox, |
    GuiControl,, ScriptsListBox, %Tmp_List%
    return
}

DeleteScript:
{
    GuiControlGet, ScriptsListBox, MainGui:
    Loop, Parse, ScriptsListBox, |
    {
        FileDelete, %A_WorkingDir%\Scripts\%ScriptsListBox%
    }
    Tmp_List := ""
    Loop, Files, Scripts\*.*, R
    {
        Tmp_List .= A_LoopFileShortName
        Tmp_List .= "|"
    }
    GuiControl,, ScriptsListBox, |
    GuiControl,, ScriptsListBox, %Tmp_List%
    return
}

RunScript:
{
    GuiControlGet, ScriptsListBox, MainGui:
    Loop, Parse, ScriptsListBox, |
    {
        Run, %A_WorkingDir%\Scripts\%ScriptsListBox%
    }
    return
}

CreateConfig:
{
    MsgBox, Выберите папку с игрой Dota 2
    FileSelectFolder, Folder
    Folder := RegExReplace(Folder, "\\$")
    IfExist, %Folder%/game/dota/cfg/gamestate_integration/
    {
        FileCopy, SystemScripts/gamestate_integration_test.cfg, %Folder%/game/dota/cfg/gamestate_integration/gamestate_integration_test.cfg , 1
    }
    Else
    {
        FileCreateDir, %Folder%/game/dota/cfg/gamestate_integration/
        FileCopy, SystemScripts/gamestate_integration_test.cfg, %Folder%/game/dota/cfg/gamestate_integration/gamestate_integration_test.cfg , 1
    }
    IniWrite, false, settings.ini, SystemSettings, isfirsttime
    IniWrite, %Folder%, settings.ini, SystemSettings, gamefolder
    MsgBox, Перезапустите игру для применения изменений
    return
}