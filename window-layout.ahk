; This script use Ctrl + Win + [hjkl] keys to arrange windows
; each binding has setting of following window arrangments
; separeted by | sign
; Script will incrementally iterate over thos settings and
; change window position and size accordingly


; ---------------
; KEY BINDINGS
; ---------------

global Top_Left_Half := " 0, 0, 0.5, 0.5 "
global Top_Right_Corner := " 0.5, 0, 0.5, 0.5 "
global Bottom_Left_Corner :=  " 0, 0.5, 0.5, 0.5 "
global Bottom_Right_Corner := " 0.5, 0.5, 0.5, 0.5 "

global Left_Half := " 0, 0, 0.5, 1 "
global Right_Half := " 0.5, 0, 0.5, 1 "
global Top_Half := " 0, 0, 1, 0.5 "
global Bottom_Half := " 0, 0.5, 1, 0.5 "

global Top_Left_OneThird := " 0, 0, 0.3333, 0.5 "
global Top_Center_OneThird := " 0.3333, 0, 0.3333, 0.5 "
global Top_Right_OneThird := " 0.6666, 0, 0.3333, 0.5 "

global Bottom_Left_OneThird := " 0, 0.5, 0.3333, 0.5 "
global Bottom_Center_OneThird := " 0.3333, 0.5, 0.3333, 0.5 "
global Bottom_Right_OneThird := " 0.6666, 0.5, 0.3333, 0.5 "

global Next := " | "

^#h::Send {Shift down}{LWin down }{ Left down}
^#l::Send {Shift down}{LWin down}{ Right down}

;^#h::
;Settings := Left_Half
    ;. Next . " 0, 0, 0.3333, 1 "
    ;. Next . " 0, 0, 0.6666, 1 "
;ToggleWindowPosition(Settings, "Left")
;return

;^#l::
;Settings := Right_Half
    ;. Next . Top_Right_Corner
    ;. Next . Bottom_Right_Corner
    ;. Next . " 0.3333, 0, 0.6666, 1 "
;ToggleWindowPosition(Settings, "Right")
;return

^#j::
Settings := Bottom_Half
    . Next . Bottom_Left_Corner
    . Next . Bottom_Right_Corner
ToggleWindowPosition(Settings, "Bottom")
return

^#k::
Settings := Top_Half
    . Next . Top_Left_Half
    . Next . Top_Right_Corner
ToggleWindowPosition(Settings, "Top")
return


; Q W E
^#q:: ToggleWindowPosition(Top_Left_Half
    . Next . Top_Left_OneThird
    , "Q")
+^#w:: ToggleWindowPosition(Top_Half
    . Next . Top_Center_OneThird
    , "W")
+^#e:: ToggleWindowPosition(Top_Right_Corner
    . Next . Top_Right_OneThird
    , "E")

; A S D
+^#a:: ToggleWindowPosition(Left_Half
    . Next . "0, 0, 0.3333, 1"
    . Next . "0, 0, 0.6666, 1"
    , "A")
+^#s:: SetWindowPositionTo("0, 0, 1, 1") ; Maximize window
+^#d:: ToggleWindowPosition(Right_Half
    . Next . "0.3333, 0, 0.6666, 1"
    . Next . "0.6666, 0, 0.3333, 1"
    , "D")

; Z X C
+^#z:: ToggleWindowPosition(Bottom_Left_Corner
    . Next . Bottom_Left_OneThird
    , "Z")
+^#x:: ToggleWindowPosition(Bottom_Half
    . Next . Bottom_Center_OneThird
    , "X")
+^#c:: ToggleWindowPosition(Bottom_Right_Corner
    . Next . Bottom_Right_OneThird
    , "C")


+#m::
    WinGet MX, MinMax, A
    IF (MX) {
        WinRestore A
        }
    else
        WinMaximize A
return

^#n:: WinMinimize A

; ---------------
; FUNCTIONS
; ---------------

SetWindowPositionTo(Setting){
    ParseScale(Setting)
    PositionWindow()
}

ToggleWindowPosition(Settings, Side) {

    CurrentMove := Side
    ResetIfCounterOverLimit(Settings)
    ResetIfDifferentWindow()

    setting := GetSettingOnIndex(Settings, Counter)
    ParseScale(setting)

    PositionWindow()

    Counter += 1
}

global LastWindowTitle := ""
global LastMove := ""
global Counter := 1

global CurrentMove := ""

ResetIfCounterOverLimit(Settings){
    settingsCount := GetSettingOnIndex(Settings, 0)
    if (!Counter || Counter > settingsCount) {
        Counter := 1
    }
}

ResetIfDifferentWindow(){
    WinGetTitle, Title, A
    if( LastMove <> CurrentMove || LastWindowTitle <> Title){
        Counter := 1
        LastMove := CurrentMove
        LastWindowTitle := Title
    }
}

GetSettingOnIndex(Array, Index){
    StringSplit, Arrangment, Array, `|
    return Arrangment%Index%
}

global xScale := 0
global yScale := 0
global wScale := 0
global hScale := 0

ParseScale(Array){
    StringSplit, Scale, Array, `,

    xScale := Scale1
    yScale := Scale2
    wScale := Scale3
    hScale := Scale4
}

global winCenterX := 0
global winCenterY := 0

GetWindowCenter() {
    WinGetPos, winX, winY, winW, winH, A
    ;MsgBox % "Window pos : " . winX . " " . winY
    winCenterX := winX + winW/2
    winCenterY := winY + winH/2
}

;MsgBox % "Monitor # : " . count

; TODO Add here support for many monitors
; -1900    0         1900+1680
; <--------0----------------->
; --------- --------- --------
; |       | |       | |      |
; |       | |       | |      |
; --------- --------- --------


PositionWindow(){
    GetWindowCenter()

    SysGet, primary, MonitorWorkArea
    SysGet, count, MonitorCount
    Loop, %count% {
        SysGet, m, MonitorWorkArea, %A_Index%

        if (WindowIsOnMonitor(mLeft, mRight)){
            MoveCurrentWindow(mLeft, mRight, mTop, mBottom)
        }
        ;MsgBox % " Top " . monitorTop . " right " . monitorRight . " Bottom " . monitorBottom . " Left " . monitorLeft . " Width " . monitorW . " Height " . monitorH
    }
}

WindowIsOnMonitor(mLeft, mRight){
    return mLeft <= winCenterX && winCenterX <= mRight
}

MoveCurrentWindow(left, right, top, bottom){
    monitorW := (right - left)
    monitorH := (bottom - top)

    x:= ( monitorW * xScale + left)
    y:= ( monitorH * yScale + top)
    w:= ( monitorW * wScale )
    h:= ( monitorH * hScale )

    WinRestore, A
    WinMove, A,, x, y, w, h
}

; AUTO RELOAD SCRIPT AFTER SAVE
~^s::
IfWinActive, %A_ScriptName%
{
    SplashTextOn,,,Updated script,
        Sleep, 200
            SplashTextOff
            Reload
}
return
