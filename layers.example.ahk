; =====================================================================
;  KEY MAP  - included by "StreamDeck Script.ahk"
;
;  Copy this file to "layers.ahk" and edit it with your own actions.
;  layers.ahk is gitignored, so your personal paths / URLs stay local.
;
;  Key names are the strings sent by the LuaMacros script
;  (see luamacros/script.example.lua).
;  Note: number-row keys use integer keys (L[1]), everything else strings.
; =====================================================================
BuildLayers() {
    RDP := A_ScriptDir "\rdp\"            ; folder holding your .rdp files
    DEV := "C:\path\to\your\programs\"    ; shortcut for a folder you use a lot

    ; ------------------------- DEFAULT LAYER -------------------------
    L := layers["default"] := {}

    L["tab"] := ToggleLayer("alt")        ; switches the whole keyboard to the "alt" layer

    ; Open() runs anything Windows can open: URLs, programs, folders, files, shortcuts
    L["F1"] := Open("https://example.com")
    L["F2"] := Open("http://192.168.1.10:8080")
    L["F3"] := Open("https://example.com", "https://example.org")   ; several targets at once
    L["F4"] := Open("notepad.exe")
    L["F5"] := Open("C:\Windows")
    L["F6"] := Open(DEV "my_tool\my_tool.py")

    ; Number row: integer keys
    L[1] := Open("calc.exe")
    L[2] := Open("mspaint.exe")

    ; Tap(single, double): different action on single and double press
    L[9] := Tap(Open(RDP "machine1.rdp"), Open(RDP "machine2.rdp"))

    ; Keys() sends a key combination  (^ Ctrl, ! Alt, + Shift, # Win)
    ; F13-F24 combos are handy to trigger other apps (OBS, Discord, games...) without conflicts
    L["a"] := Keys("^{F13}")
    L["z"] := Keys("^{F14}")
    L["e"] := Keys("+{F13}")
    L["r"] := Keys("^c")

    ; Clip() puts text in the clipboard
    L["c"] := Clip("C:\some\path\I\paste\often")

    ; Multi() chains several actions
    L["equals"] := Multi(Open("explorer.exe"), Clip("C:\Users"))

    ; SubMenu(): the NEXT key press is looked up in that submenu, then you are back
    L["num0"] := ResetSubMenu()           ; cancel an open submenu
    L["num1"] := SubMenu("subnum1")

    ; --- submenu num1 : websites ---
    S := layers["subnum1"] := {}
    S["num1"] := Open("https://github.com")
    S["num2"] := Open("https://www.autohotkey.com/docs/v1/")
    S["num3"] := Open("https://www.youtube.com")


    ; --------------------------- ALT LAYER ---------------------------
    ; Keys not listed here do nothing while the alt layer is active.
    L := layers["alt"] := {}

    L["tab"] := ToggleLayer("default")    ; same key brings you back

    L["a"] := Keys("^+{F1}")
    L["z"] := Keys("^+{F2}")
    L["e"] := Keys("^+{F3}")

    L["num1"] := SubMenu("alt_subnum1")   ; each layer can have its own submenus

    S := layers["alt_subnum1"] := {}
    S["num1"] := Open("notepad.exe")
}
