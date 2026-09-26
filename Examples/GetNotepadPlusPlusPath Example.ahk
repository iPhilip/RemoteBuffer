#Requires AutoHotkey v2.0
#Include GetNotepadPlusPlusPath.ahk

hwnd := WinExist('ahk_class Notepad++')
if !hwnd
   throw Error('The Notepad++ window does not exist.')
MsgBox GetNotepadPlusPlusPath(hwnd, 1)
