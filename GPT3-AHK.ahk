; AutoHotkey script that enables you to use GPT3 in any input field on your computer

; -- Configuration --
#SingleInstance  ; Allow only one instance of this script to be running.

; This is the hotkey used to autocomplete prompts
HOTKEY_AUTOCOMPLETE = #o  ; Win+o
; This is the hotkey used to edit prompts
HOTKEY_INSTRUCT = #+o  ; Win+shift+o
; Models settings
MODEL_AUTOCOMPLETE_ID := "text-davinci-003" 
MODEL_AUTOCOMPLETE_MAX_TOKENS := 200
MODEL_INSTRUCT_ID := "text-davinci-edit-001" 

; -- Initialization --
; Dependencies
; WinHttpRequest: https://www.reddit.com/comments/mcjj4s
; cJson.ahk: https://github.com/G33kDude/cJson.ahk
#Include <Json>
http := WinHttpRequest()

I_Icon = GPT3-AHK.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%

Hotkey, %HOTKEY_AUTOCOMPLETE%, AutocompleteFcn
Hotkey, %HOTKEY_INSTRUCT%, InstructFcn

IfNotExist, settings.ini     
{
  InputBox, API_KEY, Please insert your OpenAI API key, API key, , 270, 145
  IniWrite, %API_KEY%, settings.ini, OpenAI, API_KEY
} 
Else
{
  IniRead, API_KEY, settings.ini, OpenAI, API_KEY  
}
Return

; -- Main commands --
; Edit the phrase
InstructFcn: 
   GetText(CutText, "Cut")
   InputBox, UserInput, Text to edit "%CutText%", Enter an instruction, , 270, 145
   if ErrorLevel {
      PutText(CutText)
   }else{
      url := "https://api.openai.com/v1/edits"
      body := {}
      body.model := MODEL_INSTRUCT_ID ; ID of the model to use.
      body.input := CutText ; The prompt to edit.
      body.instruction := UserInput ; The instruction that tells how to edit the prompt
      headers := {"Content-Type": "application/json", "Authorization": "Bearer " . API_KEY}
      SetSystemCursor()
      response := http.POST(url, JSON.Dump(body), headers, {Object:true})
      obj := JSON.Load(response.Text)
      PutText(obj.choices[1].text, "")
      RestoreCursors()
   }
   Return   

; Auto-complete the phrase 
AutocompleteFcn:
   GetText(CopiedText, "Copy")
   url := "https://api.openai.com/v1/completions"
   body := {}
   body.model := MODEL_AUTOCOMPLETE_ID ; ID of the model to use.   
   body.prompt := CopiedText ; The prompt to generate completions for
   body.max_tokens := MODEL_AUTOCOMPLETE_MAX_TOKENS ; The maximum number of tokens to generate in the completion.
   headers := {"Content-Type": "application/json", "Authorization": "Bearer " . API_KEY}
   SetSystemCursor()
   response := http.POST(url, JSON.Dump(body), headers, {Object:true})
   obj := JSON.Load(response.Text)
   PutText(obj.choices[1].text, "AddSpace")
   RestoreCursors()   
   Return

; -- Auxiliar functions --
; Copies the selected text to a variable while preserving the clipboard.
GetText(ByRef MyText = "", Option = "Copy")
{
   SavedClip := ClipboardAll
   Clipboard =
   If (Option == "Copy")
   {
      Send ^c
   }
   Else If (Option == "Cut")
   {
      Send ^x
   }
   ClipWait 0.5
   If ERRORLEVEL
   {
      Clipboard := SavedClip
      MyText =
      Return
   }
   MyText := Clipboard
   Clipboard := SavedClip
   Return MyText
}

; Send text from a variable while preserving the clipboard.
PutText(MyText, Option = "")
{
   ; Decode text
   vSize := StrPut(MyText, "CP0")
   VarSetCapacity(vUtf8, vSize)
   vSize := StrPut(MyText, &vUtf8, vSize, "CP0")
   DecodedText := StrGet(&vUtf8, "UTF-8")

   ; Save clipboard and paste MyText
   SavedClip := ClipboardAll 
   Clipboard = 
   Sleep 20
   Clipboard := DecodedText
   If (Option == "AddSpace")
   {
      Send {Right}
      Send {Space}
   }
   Send ^v
   Sleep 100
   Clipboard := SavedClip
   Return
}   

; Change system cursor 
SetSystemCursor()
{
   Cursor = %A_ScriptDir%\GPT3-AHK.ani
   CursorHandle := DllCall( "LoadCursorFromFile", Str,Cursor )

   Cursors = 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
   Loop, Parse, Cursors, `,
   {
      DllCall( "SetSystemCursor", Uint,CursorHandle, Int,A_Loopfield )
   }
}

RestoreCursors() 
{
   DllCall( "SystemParametersInfo", UInt, 0x57, UInt,0, UInt,0, UInt,0 )
}