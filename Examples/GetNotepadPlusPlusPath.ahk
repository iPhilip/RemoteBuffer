#Requires AutoHotkey v2.0
#Include ..\Lib\RemoteBuffer Class

; --------------------------------------------------------------------------------------------------
; GetNotepadPlusPlusPath(hwnd, DocIndex?, SecondaryView := false)
;
; Description:
;   Gets the path of a file opened in Notepad++.
;
; Parameters:
;   hwnd          - The handle of the Notepad++ window
;   DocIndex      - (Optional) The 1-based index of the tab in the window.
;                   If omitted, the function gets the path of the file in the active tab.
;   SecondaryView - (Optional) Boolean value that determines whether DocIndex refers to a tab in the
;                   main view or the secondary view. The secondary view is the editor pane that
;                   appears when you split the screen. If omitted, it defaults to false.
;                   If the DocIndex parameter is omitted, this parameter is ignored.
;
; Return value:
;   The path of the file in the specified or active tab.
;
; Reference:
;   https://npp-user-manual.org/docs/plugin-communication
; --------------------------------------------------------------------------------------------------

GetNotepadPlusPlusPath(hwnd, DocIndex?, SecondaryView := false) {
   static NPPM_GETFULLPATHFROMBUFFERID := 2082
   static NPPM_GETBUFFERIDFROMPOS      := 2083
   static NPPM_GETFULLCURRENTPATH      := 4025
   
   if IsSet(DocIndex) {
      BufferID := SendMessage(NPPM_GETBUFFERIDFROMPOS, DocIndex - 1, SecondaryView, hwnd)
      if !BufferID
         throw ValueError('The value of DocIndex or SecondaryView is invalid.', -1)
      NoChars := SendMessage(NPPM_GETFULLPATHFROMBUFFERID, BufferID, 0, hwnd) + 1
      if !NoChars
         throw Error('BufferID does not exist', -1)
      Path := Buffer(NoChars * 2)
      NppBuffer := RemoteBuffer(WinGetPID(hwnd), Path.Size)
      SendMessage(NPPM_GETFULLPATHFROMBUFFERID, BufferID, NppBuffer, hwnd)
   } else {
      static MAX_PATH := 260
      Path := Buffer(MAX_PATH * 2)
      NppBuffer := RemoteBuffer(WinGetPID(hwnd), Path.Size)
      if !SendMessage(NPPM_GETFULLCURRENTPATH, Path.Size, NppBuffer, hwnd)
         throw ValueError('The NPPM_GETFULLCURRENTPATH buffer is not large enough.', -1, Path.Size)
      NoChars := MAX_PATH
   }
   NppBuffer.Read(Path)
   return StrGet(Path, NoChars - 1, 'UTF-16')
}
