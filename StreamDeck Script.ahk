#NoEnv
#SingleInstance Force
#Persistent
SendMode Input
SetWorkingDir %A_ScriptDir%

global KEYFILE         := A_ScriptDir "\..\LuaMacros\keypressed.txt"   ; must match KEYFILE in the LuaMacros script
global DOUBLE_PRESS_MS := 1000   ; how long a Tap() key waits for a second press

global layers     := {}         ; layerName -> { keyName: action }
global mainLayer  := "default"  ; persistent layer, switched with ToggleLayer()
global subMenu    := ""         ; one-shot layer, cleared after the next key
global currentKey := ""
global pendingKey := ""         ; Tap() key waiting for a possible second press
global pendingTap := ""

BuildLayers()   ; defined in layers.ahk
return  ; ---- end of auto-execute ----


~F24::
    FileRead, key, %KEYFILE%
    HandleKey(Trim(key, " `t`r`n"))
return


; =====================================================================
;  DISPATCHER
; =====================================================================
HandleKey(key) {
    currentKey := key

    ; A Tap() key is waiting: same key = double press, other key = settle it as a single press
    if (pendingKey != "") {
        tap := pendingTap, prev := pendingKey
        pendingKey := "", pendingTap := ""
        SetTimer, TapTimeout, Off
        if (prev = key)
            return tap.double.Call()
        tap.single.Call()
    }

    ; One-shot submenu: use its action if it has one, otherwise drop out of it
    if (subMenu != "") {
        action := layers[subMenu][key]
        subMenu := ""
        if (action)
            return action.Call()
    }

    action := layers[mainLayer][key]
    if (action)
        action.Call()
}

TapTimeout() {
    if (pendingKey = "")
        return
    tap := pendingTap
    pendingKey := "", pendingTap := ""
    tap.single.Call()
}


; =====================================================================
;  ACTION BUILDERS  - each returns a function object to call later
; =====================================================================
Open(targets*) {
    return Func("DoOpen").Bind(targets)
}
Keys(seq) {
    return Func("DoSend").Bind(seq)
}
Clip(text) {
    return Func("DoClip").Bind(text)
}
Multi(actions*) {
    return Func("DoMulti").Bind(actions)
}
SubMenu(name) {
    return Func("DoSubMenu").Bind(name)
}
ToggleLayer(name) {
    return Func("DoToggleLayer").Bind(name)
}
Tap(single, double) {
    return Func("DoTap").Bind(single, double)
}
ResetSubMenu() {
    return Func("DoResetSubMenu")
}


DoOpen(targets) {
    for _, t in targets
        Run, %t%
}
DoSend(seq) {
    Send %seq%
}
DoClip(text) {
    Clipboard := text
}
DoMulti(actions) {
    for _, a in actions
        a.Call()
}
DoSubMenu(name) {
    subMenu := name
}
DoToggleLayer(name) {
    mainLayer := (mainLayer = name) ? "default" : name
    subMenu := ""
}
DoTap(single, double) {
    pendingKey := currentKey
    pendingTap := {single: single, double: double}
    SetTimer, TapTimeout, % -DOUBLE_PRESS_MS
}
DoResetSubMenu() {
    subMenu := ""
}


#Include %A_ScriptDir%\layers.ahk