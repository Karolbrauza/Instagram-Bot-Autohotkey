
/*
===========================================
  FindText - Capture screen image into text and then find it
  https://autohotkey.com/boards/viewtopic.php?f=6&t=17834

  Author  :  FeiYue
  Version :  5.9
  Date    :  2018-07-20

  Usage:
  1. Capture the image to text string.
  2. Test find the text string on full Screen.
  3. When test is successful, you may copy the code
     and paste it into your own script.
     Note: Copy the "FindText()" function and the following
     functions and paste it into your own script Just once.

===========================================
  Introduction of function parameters:

  returnArray := FindText(
    center point X
    , center point Y
    , Left and right offset to the center point W
    , Up and down offset to the center point H
    , Character "0" fault-tolerant in percentage --> 0.1=10%
    , Character "_" fault-tolerant in percentage --> 0.1=10%
    , text --> The Base64 encoding string for the text to find
    )

  parameters of the X,Y is the center of the coordinates,
  and the W,H is the offset distance to the center,
  So the search range is (X-W, Y-H)-->(X+W, Y+H).

  The fault-tolerant parameters allow the loss of specific characters.

  Text parameters can be a lot of text to find, separated by "|".

  return is a array, contains the [X,Y,W,H,Comment] results of Each Find,
  if no image is found, the function returns 0.

===========================================
*/

#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
SetWorkingDir, %A_ScriptDir%
Menu, Tray, Icon, Shell32.dll, 23
Menu, Tray, Add
Menu, Tray, Add, Main_Window
Menu, Tray, Default, Main_Window
Menu, Tray, Click, 1
; The capture range can be changed by adjusting the numbers
;----------------------------
  ww:=70, hh:=15
;----------------------------
nW:=2*ww+1, nH:=2*hh+1
Gosub, MakeCaptureWindow
Gosub, MakeMainWindow
Gosub, Load_ToolTip_Text
OnExit, savescr
Gosub, readscr
return


F12::    ; Hotkey --> Reload
SetTitleMatchMode, 2
SplitPath, A_ScriptName,,,, name
IfWinExist, %name%
{
  ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
  Sleep, 500
}
Reload
return


Load_ToolTip_Text:
ToolTip_Text=
(LTrim
Capture   = Initiate Image Capture Sequence
Test      = Test Results of Code
Copy      = Copy Code to Clipboard
AddFunc   = Additional FindText() in Copy
U         = Cut the Upper Edge by 1
U3        = Cut the Upper Edge by 3
L         = Cut the Left Edge by 1
L3        = Cut the Left Edge by 3
R         = Cut the Right Edge by 1
R3        = Cut the Right Edge by 3
D         = Cut the Lower Edge by 1
D3        = Cut the Lower Edge by 3
Auto      = Automatic Cutting Edge`r`nOnly after Color2Two or Gray2Two
Similar   = Adjust color similarity as Equivalent to The Selected Color
SelCol    = Selected Image Color which Determines Black or Pixel White Conversion (Hex of Color)
Gray      = Grayscale Threshold which Determines Black or White Pixel Conversion (0-255)
Color2Two = Converts Image Pixels from Color to Black or White`r`nDepending on Selection Color and Sensitivity
Gray2Two  = Converts Image Pixels from Grays to Black or White`r`nDepending on Gray Threshold
Modify    = Allows for Pixel Cleanup of Black and White Image`r`nOnly After Gray2Two or Color2Two
Reset     = Reset to Original Captured Image
Comment   = Optional Comment used to Label Code ( Within <> )
SplitAdd  = Using Markup Segmentation to Generate Text Library
AllAdd    = Append Another FindText Search Text into Previously Generated Code
OK        = Create New FindText Code for Testing
Close     = Close the Window Don't Do Anything
)
return

readscr:
f=%A_Temp%\~scr.tmp
FileRead, s, %f%
GuiControl, Main:, scr, %s%
s=
return

savescr:
f=%A_Temp%\~scr.tmp
GuiControlGet, s, Main:, scr
FileDelete, %f%
FileAppend, %s%, %f%
ExitApp

Main_Window:
Gui, Main:Show, Center
return

MakeMainWindow:
Gui, Main:Default
Gui, +AlwaysOnTop
Gui, Margin, 15, 15
Gui, Color, DDEEFF
Gui, Font, s6 bold, Verdana
Gui, Add, Edit, xm w660 r25 vMyEdit -Wrap -VScroll
Gui, Font, s12 norm, Verdana
Gui, Add, Button, w220 gMainRun, Capture
Gui, Add, Button, x+0 wp gMainRun, Test
Gui, Add, Button, x+0 wp gMainRun Section, Copy
Gui, Font, s10
Gui, Add, Text, xm, Click Text String to See ASCII Search Text in the Above
Gui, Add, Checkbox, xs yp w220 r1 -Wrap Checked vAddFunc, Additional FindText() in Copy
Gui, Font, s12 cBlue, Verdana
Gui, Add, Edit, xm w660 h350 vscr Hwndhscr -Wrap HScroll
Gui, Show,, Capture Image To Text And Find Text Tool
;---------------------------------------
OnMessage(0x100, "EditEvents1")  ; WM_KEYDOWN
OnMessage(0x201, "EditEvents2")  ; WM_LBUTTONDOWN
OnMessage(0x200, "WM_MOUSEMOVE") ; Show ToolTip
return

EditEvents1()
{
  ListLines, Off
  if (A_Gui="Main") and (A_GuiControl="scr")
    SetTimer, ShowText, -100
}

EditEvents2()
{
  ListLines, Off
  if (A_Gui="Capture")
    WM_LBUTTONDOWN()
  else
    EditEvents1()
}

ShowText:
ListLines, Off
Critical
ControlGet, i, CurrentLine,,, ahk_id %hscr%
ControlGet, s, Line, %i%,, ahk_id %hscr%
s := ASCII(s)
GuiControl, Main:, MyEdit, % Trim(s,"`n")
return

MainRun:
k:=A_GuiControl
WinMinimize
Gui, Hide
DetectHiddenWindows, Off
Gui, +LastFound
WinWaitClose, % "ahk_id " WinExist()
if IsLabel(k)
  Gosub, %k%
Gui, Main:Show
GuiControl, Main:Focus, scr
return

Copy:
GuiControlGet, s,, scr
GuiControlGet, AddFunc
if AddFunc != 1
  s:=RegExReplace(s,"\n\K[\s;=]+ Copy The[\s\S]*")
Clipboard:=StrReplace(s,"`n","`r`n")
s=
return

Capture:
Gui, Mini:Default
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x08000000
WinSet, Transparent, 200
Gui, Color, Red
x:=nW+2, y:=nH+2, w:=nW+4, h:=nH+4
Gui, Show, Hide w%w% h%h%
WinSet, Region
  , 0-0 %w%-0 %w%-%h% 0-%h% 0-0 2-2 %x%-2 %x%-%y% 2-%y% 2-2
;------------------------------
Hotkey, $*RButton, _RButton_Off, On
ListLines, Off
oldx:=oldy:=""
Loop {
  MouseGetPos, x, y
  if (oldx=x and oldy=y)
    Continue
  oldx:=x, oldy:=y, px:=x, py:=y
  Gui, Show, % "NA x" (px-w//2) " y" (py-h//2)
  ToolTip, % "The Capture Position : " px "," py
    . "`nMove and Press RButton to start capture"
    . "`nMove and Release RButton to end capture"
  Sleep, 50
} Until GetKeyState("RButton","P")
oldx:=oldy:=""
Loop {
  MouseGetPos, x, y
  if (oldx=x and oldy=y)
    Continue
  oldx:=x, oldy:=y
  ToolTip, % "The Capture Position : " px "," py
    . "`nMove and Press RButton to start capture"
    . "`nMove and Release RButton to end capture"
  Sleep, 50
} Until !GetKeyState("RButton","P")
ToolTip
ListLines, On
Gui, Destroy
WinWaitClose
cors:=getc(px,py,ww,hh)
Hotkey, $*RButton, _RButton_Off, Off
Goto, ShowCaptureWindow
_RButton_Off:
return

ShowCaptureWindow:
cors.Event:="", cors.Result:=""
;--------------------------------
Gui, Capture:Default
k:=nW*nH+1
Loop, % nW
  GuiControl,, % C_[k++], 0
GuiControl,, SelCol
GuiControl,, Gray
GuiControl,, Modify, % Modify:=0
GuiControl, Focus, Gray
Gosub, Reset
Gui, Show, Center
DetectHiddenWindows, Off
Gui, +LastFound
WinWaitClose, % "ahk_id " WinExist()
;--------------------------------
if InStr(cors.Event,"OK")
{
  if !A_IsCompiled
  {
    FileRead, fs, %A_ScriptFullPath%
    fs:=SubStr(fs,fs~="i)\n[;=]+ Copy The")
  }
  GuiControl, Main:, scr, % cors.Result "`n" fs
  cors.Result:=fs:=""
  return
}
if InStr(cors.Event,"Add")
  add(cors.Result, 0), cors.Result:=""
return

WM_LBUTTONDOWN()
{
  global
  ListLines, Off
  MouseGetPos,,,, mclass
  IfNotInString, mclass, progress
    return
  MouseGetPos,,,, mid, 2
  For k,v in C_
    if (v=mid)
    {
      if (k>nW*nH)
      {
        GuiControlGet, i, Capture:, %v%
        GuiControl, Capture:, %v%, % i ? 0:100
      }
      else if (Modify and bg!="")
      {
        c:=cc[k], cc[k]:=c="0" ? "_" : c="_" ? "0" : c
        c:=c="0" ? "White" : c="_" ? "Black" : WindowColor
        Gosub, SetColor
      }
      else
      {
        GuiControl, Capture:, SelCol, % cors[k]
        cors.Color:=cors[k]
      }
      return
    }
}

getc(px, py, ww, hh)
{
  xywh2xywh(px-ww,py-hh,2*ww+1,2*hh+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  cors:=[], k:=0, nW:=2*ww+1, nH:=2*hh+1
  ListLines, Off
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, H
  Loop, %nH% {
    j:=py-hh-y+A_Index-1
    Loop, %nW% {
      i:=px-ww-x+A_Index-1, k++
      if (i>=0 and i<w and j>=0 and j<h)
        c:=NumGet(Scan0+0,i*4+j*Stride,"uint")
          , cors[k]:="0x" . SubStr(0x1000000|c,-5)
      else
        cors[k]:="0xFFFFFF"
    }
  }
  SetFormat, IntegerFast, %fmt%
  ListLines, On
  cors.LeftCut:=Abs(px-ww-x)
  cors.RightCut:=Abs(px+ww-(x+w-1))
  cors.UpCut:=Abs(py-hh-y)
  cors.DownCut:=Abs(py+hh-(y+h-1))
  SetBatchLines, %bch%
  return, cors
}

Test:
GuiControlGet, s, Main:, scr
s:="`n#NoEnv`nMenu, Tray, Click, 1`n"
  . "Gui, _ok_:Show, Hide, _ok_`n"
  . s "`nExitApp`n#SingleInstance off`n"
if (!A_IsCompiled) and InStr(s,"MCode(")
{
  Exec(s)
  DetectHiddenWindows, On
  WinWait, _ok_ ahk_class AutoHotkeyGUI,, 3
  WinWaitClose, _ok_ ahk_class AutoHotkeyGUI,, 3
}
else
{
  t1:=A_TickCount
  RegExMatch(s,"=""\K[^\n]+?\d\.[\w+/]{3,}",Text)
  ok:=FindText(0, 0, 150000, 150000, 0, 0, Text)
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  MsgBox, 4096,, % "Time:`t" (A_TickCount-t1) " ms`n`n"
    . "Pos:`t" X ", " Y "`n`n"
    . "Result:`t" (ok ? "Success !":"Failed !"), 3
  MouseMove, X, Y
}
return

Exec(s)
{
  Ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe":A_AhkPath
  s:=RegExReplace(s, "\R", "`r`n")
  Try {
    oExec:=ComObjCreate("WScript.Shell").Exec(Ahk " /r *")
    oExec.StdIn.Write(s)
    oExec.StdIn.Close()
  }
  catch {
    s:="`r`nFileDelete, %A_ScriptFullPath%`r`n" . s
    f:=A_Temp "\~test.tmp"
    FileDelete, %f%
    FileAppend, %s%, %f%
    Run, %Ahk% /r "%f%"
  }
}

MakeCaptureWindow:
WindowColor:="0xCCDDEE"
Gui, Capture:Default
Gui, +LastFound +AlwaysOnTop +ToolWindow
Gui, Margin, 15, 15
Gui, Color, %WindowColor%
Gui, Font, s14, Verdana
ListLines, Off
Gui, -Theme
w:=800//nW, h:=(A_ScreenHeight-300)//nH, w:=h<w ? h-1:w-1
Loop, % nW*(nH+1) {
  i:=A_Index, j:=i=1 ? "" : Mod(i,nW)=1 ? "xm y+1" : "x+1"
  j.=i>nW*nH ? " cRed BackgroundFFFFAA":""
  Gui, Add, Progress, w%w% h%w% %j%
}
WinGet, s, ControlListHwnd
C_:=StrSplit(s,"`n"), s:=""
Loop, % nW*(nH+1)
  Control, ExStyle, -0x20000,, % "ahk_id " C_[A_Index]
Gui, +Theme
ListLines, On
Gui, Add, Button, xm+95  w45 gUpCut Section, U
Gui, Add, Button, x+0    wp gUpCut3, U3
Gui, Add, Text,   xm+310 yp+6 Section, Color Similarity  0
Gui, Add, Slider
  , x+0 w250 vSimilar Page1 NoTicks ToolTip Center, 100
Gui, Add, Text,   x+0, 100
Gui, Add, Button, xm     w45 gLeftCut, L
Gui, Add, Button, x+0    wp gLeftCut3, L3
Gui, Add, Button, x+15   w70 gRun, Auto
Gui, Add, Button, x+15   w45 gRightCut, R
Gui, Add, Button, x+0    wp gRightCut3, R3
Gui, Add, Text,   xs     w160 yp, Selected  Color
Gui, Add, Edit,   x+15   w140 vSelCol
Gui, Add, Button, x+15   w145 gRun, Color2Two
Gui, Add, Button, xm+95  w45 gDownCut, D
Gui, Add, Button, x+0    wp gDownCut3, D3
Gui, Add, Text,   xs     w160 yp, Gray Threshold
Gui, Add, Edit,   x+15   w140 vGray
Gui, Add, Button, x+15   w145 gRun Default, Gray2Two
Gui, Add, Checkbox, xm   y+21 gRun vModify, Modify
Gui, Add, Button, x+5    yp-6 gRun, Reset
Gui, Add, Text,   x+20   yp+6, Comment
Gui, Add, Edit,   x+5    w132 vComment
Gui, Add, Button, x+10   yp-6 gRun, SplitAdd
Gui, Add, Button, x+10   gRun, AllAdd
Gui, Add, Button, x+10   w80 gRun, OK
Gui, Add, Button, x+10   gCancel, Close
Gui, Show, Hide, Capture Image To Text
return

Run:
Critical
k:=A_GuiControl
Gui, +OwnDialogs
if IsLabel(k)
  Goto, %k%
return

Modify:
GuiControlGet, Modify
return

SetColor:
c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
  : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
return

Reset:
if !IsObject(cc)
  cc:=[], gc:=[], pp:=[]
left:=right:=up:=down:=k:=0, bg:=""
Loop, % nW*nH {
  cc[++k]:=1, c:=cors[k], gc[k]:=(((c>>16)&0xFF)*299
    +((c>>8)&0xFF)*587+(c&0xFF)*114)//1000
  Gosub, SetColor
}
Loop, % cors.LeftCut
  Gosub, LeftCut
Loop, % cors.RightCut
  Gosub, RightCut
Loop, % cors.UpCut
  Gosub, UpCut
Loop, % cors.DownCut
  Gosub, DownCut
return

Color2Two:
GuiControlGet, Similar
GuiControlGet, r,, SelCol
if r=
{
  MsgBox, 4096, Tip
    , `n  Please Select a Color First !  `n, 1
  return
}
Similar:=Round(Similar/100,2), n:=Floor(255*3*(1-Similar))
color:=r "@" Similar, k:=i:=0
rr:=(r>>16)&0xFF, gg:=(r>>8)&0xFF, bb:=r&0xFF
Loop, % nW*nH {
  if (cc[++k]="")
    Continue
  c:=cors[k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
  if Abs(r-rr)+Abs(g-gg)+Abs(b-bb)<=n
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
return

Gray2Two:
GuiControl, Focus, Gray
GuiControlGet, Threshold,, Gray
if Threshold=
{
  Loop, 256
    pp[A_Index-1]:=0
  Loop, % nW*nH
    if (cc[A_Index]!="")
      pp[gc[A_Index]]++
  IP:=IS:=0
  Loop, 256
    k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
  NewThreshold:=Floor(IP/IS)
  Loop, 20 {
    Threshold:=NewThreshold
    IP1:=IS1:=0
    Loop, % Threshold+1
      k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
    IP2:=IP-IP1, IS2:=IS-IS1
    if (IS1!=0 and IS2!=0)
      NewThreshold:=Floor((IP1/IS1+IP2/IS2)/2)
    if (NewThreshold=Threshold)
      Break
  }
  GuiControl,, Gray, %Threshold%
}
color:="*" Threshold, k:=i:=0
Loop, % nW*nH {
  if (cc[++k]="")
    Continue
  if (gc[k]<Threshold+1)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"
return

gui_del:
cc[k]:="", c:=WindowColor
Gosub, SetColor
return

LeftCut3:
Loop, 3
  Gosub, LeftCut
return

LeftCut:
if (left+right>=nW)
  return
left++, k:=left
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
return

RightCut3:
Loop, 3
  Gosub, RightCut
return

RightCut:
if (left+right>=nW)
  return
right++, k:=nW+1-right
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
return

UpCut3:
Loop, 3
  Gosub, UpCut
return

UpCut:
if (up+down>=nH)
  return
up++, k:=(up-1)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
return

DownCut3:
Loop, 3
  Gosub, DownCut
return

DownCut:
if (up+down>=nH)
  return
down++, k:=(nH-down)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
return

getwz:
wz=
if bg=
  return
ListLines, Off
k:=0
Loop, %nH% {
  v=
  Loop, %nW%
    v.=cc[++k]
  wz.=v="" ? "" : v "`n"
}
ListLines, On
return

Auto:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  return
}
While InStr(wz,bg) {
  if (wz~="^" bg "+\n")
  {
    wz:=RegExReplace(wz,"^" bg "+\n")
    Gosub, UpCut
  }
  else if !(wz~="m`n)[^\n" bg "]$")
  {
    wz:=RegExReplace(wz,"m`n)" bg "$")
    Gosub, RightCut
  }
  else if (wz~="\n" bg "+\n$")
  {
    wz:=RegExReplace(wz,"\n\K" bg "+\n$")
    Gosub, DownCut
  }
  else if !(wz~="m`n)^[^\n" bg "]")
  {
    wz:=RegExReplace(wz,"m`n)^" bg)
    Gosub, LeftCut
  }
  else Break
}
wz=
return

OK:
AllAdd:
SplitAdd:
Gosub, getwz
if wz=
{
  MsgBox, 4096, Tip
    , `nPlease Click Color2Two or Gray2Two First !, 1
  return
}
if InStr(color,"@")
{
  StringSplit, r, color, @
  k:=i:=j:=0
  Loop, % nW*nH {
    if (cc[++k]="")
      Continue
    i++
    if (cors[k]=r1)
    {
      j:=i
      Break
    }
  }
  if (j=0)
  {
    MsgBox, 4096, Tip
      , Please select the reference color again !, 2
    return
  }
  color:=j . "@" . r2
}
GuiControlGet, Comment
Gui, Hide
cors.Event:=A_ThisLabel
if A_ThisLabel=SplitAdd
{
  SetFormat, IntegerFast, d
  bg:=StrLen(StrReplace(wz,"_"))
    > StrLen(StrReplace(wz,"0")) ? "0":"_"
  s:="", k:=nW*nH+1+left, i:=0, w:=nW-left-right
  Loop, % w {
    i++
    GuiControlGet, j,, % C_[k++]
    if (j=0 and A_Index<w)
      Continue
    v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
    wz:=RegExReplace(wz,"m`n)^.{" i "}"), i:=0
    While InStr(v,bg) {
      if (v~="^" bg "+\n")
        v:=RegExReplace(v,"^" bg "+\n")
      else if !(v~="m`n)[^\n" bg "]$")
        v:=RegExReplace(v,"m`n)" bg "$")
      else if (v~="\n" bg "+\n$")
        v:=RegExReplace(v,"\n\K" bg "+\n$")
      else if !(v~="m`n)^[^\n" bg "]")
        v:=RegExReplace(v,"m`n)^" bg)
      else Break
    }
    if v!=
      s.=towz(color,v,SubStr(Comment,1,1))
    Comment:=SubStr(Comment,2)
  }
  cors.Result:=s
  return
}
s:=towz(color,wz,Comment)
if A_ThisLabel=AllAdd
{
  cors.Result:=s
  return
}
px1:=px-ww+left+(nW-left-right)//2
py1:=py-hh+up+(nH-up-down)//2
s:=StrReplace(s, "Text.=", "Text:=")
s=
(

t1:=A_TickCount
%s%
if (ok:=FindText(%px1%, %py1%, 150000, 150000, 0, 0, Text))
{
  CoordMode, Mouse
  X:=ok.1.1, Y:=ok.1.2, W:=ok.1.3, H:=ok.1.4, Comment:=ok.1.5, X+=W//2, Y+=H//2
  ; Click, `%X`%, `%Y`%
}

MsgBox, 4096,, `% "Time:``t" (A_TickCount-t1) " ms``n``n"
  . "Pos:``t" X ", " Y "``n``n"
  . "Result:``t" (ok ? "Success !":"Failed !"), 3
MouseMove, X, Y

)
cors.Result:=s
return

towz(color,wz,comment="")
{
  SetFormat, IntegerFast, d
  wz:=StrReplace(StrReplace(wz,"0","1"),"_","0")
  wz:=(InStr(wz,"`n")-1) "." bit2base64(wz)
  return, "`nText.=""|<" comment ">" color "$" wz """`n"
}

add(s, rn=1)
{
  global hscr
  if (rn=1)
    s:="`n" s "`n"
  s:=RegExReplace(s,"\R","`r`n")
  ControlGet, i, CurrentCol,,, ahk_id %hscr%
  if i>1
    ControlSend,, {Home}{Down}, ahk_id %hscr%
  Control, EditPaste, %s%,, ahk_id %hscr%
}

WM_MOUSEMOVE()
{
  ListLines, Off
  static CurrControl, PrevControl
  CurrControl := A_GuiControl
  if (CurrControl!=PrevControl)
  {
    PrevControl := CurrControl
    ToolTip
    if CurrControl !=
      SetTimer, DisplayToolTip, -1000
  }
  return

  DisplayToolTip:
  ListLines, Off
  k:="ToolTip_Text"
  TT_:=RegExMatch(%k%, "m`n)^" CurrControl "\K\s*=.*", r)
    ? Trim(r,"`t =") : ""
  MouseGetPos,,, k
  WinGetClass, k, ahk_id %k%
  if k = AutoHotkeyGUI
  {
    ToolTip, %TT_%
    SetTimer, RemoveToolTip, -5000
  }
  return

  RemoveToolTip:
  ToolTip
  return
}


;===== Copy The Following Functions To Your Own Code Just once =====


; Note: parameters of the X,Y is the center of the coordinates,
; and the W,H is the offset distance to the center,
; So the search range is (X-W, Y-H)-->(X+W, Y+H).
; err1 is the character "0" fault-tolerant in percentage.
; err0 is the character "_" fault-tolerant in percentage.
; Text can be a lot of text to find, separated by "|".
; ruturn is a array, contains the [X,Y,W,H,Comment] results of Each Find.

FindText(x,y,w,h,err1,err0,text)
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h, arr:=[]
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    ;--------------------------------------------
    mode:=InStr(color,"*") ? 1:0
    color:=StrReplace(color,"*") . "@"
    StringSplit, r, color, @
    color:=mode=1 ? r1 : ((r1-1)//w1)*Stride+Mod(r1-1,w1)*4
    n:=Round(r2,2)+(!r2), n:=Floor(255*3*(1-n))
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    VarSetCapacity(allpos, 1024*4, 0), k:=StrLen(v)*4
    VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
    ;--------------------------------------------
    if (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*e1),Round(len0*e0),w1,h1,allpos))
      or (err1=0 and err0=0
      and (ok:=PicFind(mode,color,n,Scan0,Stride,sx,sy,sw,sh
      ,v,s1,s0,Round(len1*0.1),Round(len0*0.1),w1,h1,allpos)))
    {
      Loop, % ok
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
        , arr.Push( [rx,ry,w1,h1,comment] )
    }
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind(mode, color, n, Scan0, Stride, sx, sy, sw, sh
  , ByRef text, ByRef s1, ByRef s0
  , err1, err0, w1, h1, ByRef allpos)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5557565383EC488B4424782B8424940000008B742470894"
    . "4242083C001894424348B44247C2B842498000000894424188"
    . "3C0018944241C8B4424740FAF44246C8D04B0894424148B842"
    . "49800000085C00F8E9F04000031ED31FF31F6892C248BAC248"
    . "800000031DB897C24048D7426008B84249400000085C07E568"
    . "B8424800000008B8C24800000008B54240401D8039C2494000"
    . "00001D9895C2408EB13669083C0018954B50083C60183C2043"
    . "9C1741C80383175EA8B9C248400000083C0018914BB83C7018"
    . "3C20439C175E48B5C2408830424018B54246C8B04240154240"
    . "439842498000000758789F839F7897C24100F4CC68944240C8"
    . "B44245C85C00F85E90100008B44241C85C00F8EDE0300008B4"
    . "4241403442460034424688B7C2418897424148B742468C7442"
    . "43000000000894424408B442474894424388D4407018B7C247"
    . "0894424448B4424208D4438018B7C24608944242C8B4424680"
    . "1F8894424288B7C243485FF0F8E560100008B442438C1E0108"
    . "944243C8B442470894424188B442440894424248DB42600000"
    . "0008B4424248B6C240C0FB6580289C72B7C242885ED891C240"
    . "FB658010FB600895C2404894424080F84D50200008B8424900"
    . "0000031DB894424208B84248C0000008944241CEB778D76008"
    . "DBC27000000003B5C24147D5A8B8424880000008B149801FA0"
    . "FB64C16020FB64416012B0C242B4424040FB614162B5424088"
    . "9CDC1FD1F31E929E989C5C1FD1F31E829E889D5C1FD1F01C13"
    . "1EA29EA01CA395424647C10836C242001787589F68DBC27000"
    . "0000083C3013B5C240C0F8444020000395C24107E8D8B8C248"
    . "40000008B049901F80FB64C06020FB65406012B0C242B54240"
    . "40FB604062B44240889CDC1FD1F31E929E989D5C1FD1F31EA2"
    . "9EA89C5C1FD1F01D131E829E801C83B4424640F8E3FFFFFFF8"
    . "36C241C010F8934FFFFFF834424180183442424048B4424183"
    . "944242C0F85CCFEFFFF83442438018B7C246C8B442438017C2"
    . "4403B4424440F8583FEFFFF8B44243083C4485B5E5F5DC2440"
    . "08B4424608B5C247C83C00169E8E80300008B4424140344246"
    . "889C78B442478C1E00289042431C085DB7E548974240489FE8"
    . "9C78B4C247885C97E338B042489F18D1C060FB651020FB6410"
    . "169D22B01000069C04B02000001C20FB6016BC07201D039C50"
    . "F9F410383C10439CB75D583C7010374246C397C247C75B88B7"
    . "424048B4424148B54241C83C00385D20F8E6F0100008B7C241"
    . "88944242489F58B4424748B7424108B5C240CC744241800000"
    . "0008944241C8D4407018B7C2470894424288B4424208D44380"
    . "1894424148B44243485C00F8EA80000008B44241CC1E010894"
    . "424108B4424708904248B4424248944240C9085DB0F84D8000"
    . "0008B8424900000008B94248C0000008B4C240C034C2468894"
    . "424088954240431C0EB318DB60000000039E87D1C8B9424880"
    . "000008B3C8201CF803F00740B836C240801782B8D74260083C"
    . "00139D80F848500000039C67ED18B9424840000008B3C8201C"
    . "F803F0174C0836C24040179B9830424018344240C048B04243"
    . "B4424140F8573FFFFFF8344241C018B7C246C8B44241C017C2"
    . "424394424280F8531FFFFFF8B442418E952FEFFFF8B7C24308"
    . "B5424180B54243C8B9C249C00000089F883C0013DFF0300008"
    . "914BB0F8F2CFEFFFF89442430E9ECFDFFFF8B7C24188B14240"
    . "B5424108B8C249C00000089F883C0013DFF0300008914B90F8"
    . "FFEFDFFFF89442418E969FFFFFF31C0E9EEFDFFFFC744240C0"
    . "000000031F6C744241000000000E9ECFBFFFF90909090"
    x64:="4157415641554154555756534883EC488BAC24000100008"
    . "B8424C80000008BBC24080100008BB424B80000004D89CC898"
    . "C24900000008994249800000029E844898424A00000004C8BA"
    . "C24E00000008944240883C001488B9C24E8000000894424148"
    . "B8424D000000029F88944240C83C001894424048B8424C0000"
    . "0000FAF8424B000000085FF8D04B08904240F8E320500004C8"
    . "9A424A80000004C8BA424D80000008D34AD000000004531C94"
    . "531D24531F64531FF4531DB0F1F800000000085ED7E454963D"
    . "3468D040E4489C84C01E2EB164963CE4883C2014183C601890"
    . "48B83C0044139C0741D803A3175E54963CF4883C2014183C70"
    . "14189448D0083C0044139C075E34101EB4183C20144038C24B"
    . "00000004439D775A64C8BA424A80000004539F74489F5410F4"
    . "DEF448B9424900000004585D20F8547020000448B4C2404458"
    . "5C90F8E73040000486304244863BC24B00000008BB424B8000"
    . "000C7442410000000004C89AC24E000000048899C24E800000"
    . "08944243848897C243048894424208B7C240C8B8424C000000"
    . "0894424188D4407018944243C4863842498000000488944242"
    . "88B4424088D4430018944240C448B4424144585C00F8E85010"
    . "0008B442418448B5C2438C1E0108944241C488B44242048034"
    . "424284D8D2C048B8424B8000000890424660F1F44000085ED4"
    . "10FB65D02410FB67501410FB67D000F84490300008B8424F80"
    . "000004531C0894424088B8424F000000089442404E98800000"
    . "04539CE7E76488B8C24E8000000428B04814401D88D5002486"
    . "3D2410FB60C148D50014898410FB604044863D2410FB614142"
    . "9D94189C929F841C1F91F29F24431C94429C94189D141C1F91"
    . "F4431CA4429CA4189C141C1F91F01D14431C84429C801C8398"
    . "424A00000007C10836C2408010F88930000000F1F440000498"
    . "3C0014439C50F8EA30200004539C74589C10F8E6CFFFFFF488"
    . "B8C24E0000000428B04814401D88D50024863D2410FB60C148"
    . "D50014898410FB604044863D2410FB6141429D94189CA29F84"
    . "1C1FA1F29F24431D14429D14189D241C1FA1F4431D24429D24"
    . "189C241C1FA1F01D14431D04429D001C83B8424A00000000F8"
    . "E02FFFFFF836C2404010F89F7FEFFFF830424014983C504418"
    . "3C3048B04243944240C0F85A9FEFFFF83442418018BBC24B00"
    . "000008B442418017C2438488B7C243048017C24203B44243C0"
    . "F8545FEFFFF8B4424104883C4485B5E5F5D415C415D415E415"
    . "FC38B8424980000008B8C24D0000000448D48014569C9E8030"
    . "00085C90F8E9F00000048638424B00000004C6314244531DB4"
    . "4897C24104489742418448BBC24D0000000448BB424C800000"
    . "04889C78B8424C80000004D01E283E801488D3485040000006"
    . "62E0F1F8400000000004585F67E394E8D04164C89D10F1F400"
    . "00FB651020FB6410169D22B01000069C04B02000001C20FB60"
    . "16BC07201D04139C10F9F41034883C1044939C875D24183C30"
    . "14901FA4539DF75B6448B7C2410448B7424188B04248B54240"
    . "483C00385D20F8E680100008B7C240C894424108B8424C0000"
    . "0008BB424B8000000894424048D44070131FF893C248BBC24F"
    . "80000008944240C8B442408448D5C30018B44241485C00F8E8"
    . "E0000008B4424048BB424B8000000448B442410C1E01089442"
    . "40885ED0F84C80000004189FA448B8C24F000000031C0EB356"
    . "60F1F8400000000004439F17D1B8B14834401C24863D241803"
    . "C1400740B4183EA0178300F1F4400004883C00139C50F8E840"
    . "000004439F889C17DCD418B5485004401C24863D241803C140"
    . "174BB4183E90179B583C6014183C0044439DE7589834424040"
    . "18BB424B00000008B442404017424103B44240C0F8548FFFFF"
    . "F8B3C2489F8E924FEFFFF9048635424108B0C240B4C241C488"
    . "BBC241001000089D083C001890C973DFF0300000F8FFCFDFFF"
    . "F89442410E9AEFDFFFF486314248B4C24084C8B94241001000"
    . "009F189D041890C9283C0013DFF0300000F8FCDFDFFFF83C60"
    . "14183C0048904244439DE0F85F7FEFFFFE969FFFFFF31C0E9A"
    . "EFDFFFF31ED4531F64531FFE95AFBFFFF9090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",mode
    , "uint",color, "int",n, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "AStr",text, "ptr",&s1, "ptr",&s0
    , "int",err1, "int",err0, "int",w1, "int",h1, "ptr",&allpos)
}

xywh2xywh(x1,y1,w1,h1,ByRef x,ByRef y,ByRef w,ByRef h)
{
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x1, right:=x1+w1-1, up:=y1, down:=y1+h1-1
  left:=left<zx ? zx:left, right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
}

GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride,ByRef bits)
{
  VarSetCapacity(bits,w*h*4,0), bpp:=32
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
  Ptr:=A_PtrSize ? "UPtr" : "UInt", PtrP:=Ptr . "*"
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetWindowDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  ;-------------------------
  VarSetCapacity(bi, 40, 0), NumPut(40, bi, 0, "int")
  NumPut(w, bi, 4, "int"), NumPut(-h, bi, 8, "int")
  NumPut(1, bi, 12, "short"), NumPut(bpp, bi, 14, "short")
  ;-------------------------
  if hBM:=DllCall("CreateDIBSection", Ptr,mDC, Ptr,&bi
    , "int",0, PtrP,ppvBits, Ptr,0, "int",0, Ptr)
  {
    oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
    DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w, "int",h
      , Ptr,hDC, "int",x, "int",y, "uint",0x00CC0020|0x40000000)
    DllCall("RtlMoveMemory", Ptr,Scan0, Ptr,ppvBits, Ptr,Stride*h)
    DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
    DllCall("DeleteObject", Ptr,hBM)
  }
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2),code,A_Index-1,"uchar")
  Ptr:=A_PtrSize ? "UPtr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}

base64tobit(s)
{
  ListLines, Off
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  StringCaseSense, On
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:=(i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,A_LoopField,v)
  }
  StringCaseSense, Off
  s:=SubStr(s,1,InStr(s,"1",0,0)-1)
  s:=RegExReplace(s,"[^01]+")
  ListLines, On
  return, s
}

bit2base64(s)
{
  ListLines, Off
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    . "abcdefghijklmnopqrstuvwxyz"
  SetFormat, IntegerFast, d
  Loop, Parse, Chars
  {
    i:=A_Index-1, v:="|" . (i>>5&1) . (i>>4&1)
      . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1)
    s:=StrReplace(s,v,A_LoopField)
  }
  ListLines, On
  return, s
}

ASCII(s)
{
  if RegExMatch(s,"\$(\d+)\.([\w+/]+)",r)
  {
    s:=RegExReplace(base64tobit(r2),".{" r1 "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s=
  return, s
}

; You can put the text library at the beginning of the script,
; and Use Pic(Text,1) to add the text library to Pic()'s Lib,
; Use Pic("comment1|comment2|...") to get text images from Lib

Pic(comments, add_to_Lib=0)
{
   Lib:=[]
  if (add_to_Lib)
  {
    re:="<([^>]*)>[^$]+\$\d+\.[\w+/]{3,}"
    Loop, Parse, comments, |
      if RegExMatch(A_LoopField,re,r)
        Lib[Trim(r1)]:=r
    Lib[""]:=""
  }
  else
  {
    text:=""
    Loop, Parse, comments, |
      text.="|" . Lib[Trim(A_LoopField)]
    return, text
  }
}

PicN(number)
{
  return, Pic(Trim(RegExReplace(number,".","$0|"),"|"))
}

; Use PicX(Text) to automatically cut into multiple characters

PicX(Text)
{
  if !RegExMatch(Text,"\|([^$]+)\$(\d+)\.([\w+/]+)",r)
    return, Text
  w:=r2, v:=base64tobit(r3), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  wz:=RegExReplace(v,".{" w "}","$0`n")
  SetFormat, IntegerFast, d
  While InStr(wz,c) {
    While !(wz~="m`n)^" c)
      wz:=RegExReplace(wz,"m`n)^.")
    i:=0
    While (wz~="m`n)^.{" i "}" c)
      i++
    v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
    wz:=RegExReplace(wz,"m`n)^.{" i "}")
    if v!=
      Text.="|" r1 "$" i "." bit2base64(v)
  }
  return, Text
}

FindTextOCR(nX, nY, nW, nH, err1, err0, Text, Interval=20)
{
  OCR:="", Right_X:=nX+nW
  While (ok:=FindText(nX, nY, nW, nH, err1, err0, Text))
  {
    ; For multi text search, This is the number of text images found
    Loop, % ok.MaxIndex()
    {
      ; X is the X coordinates of the upper left corner
      ; and W is the width of the image have been found
      i:=A_Index, x:=ok[i].1, y:=ok[i].2
        , w:=ok[i].3, h:=ok[i].4, comment:=ok[i].5
      ; We need the leftmost X coordinates
      if (A_Index=1 or x<Left_X)
        Left_X:=x, Left_W:=w, Left_OCR:=comment
    }
    ; If the interval exceeds the set value, add "*" to the result
    OCR.=(A_Index>1 and Left_X-Last_X>Interval ? "*":"") . Left_OCR
    ; Update nX and nW for next search
    x:=Left_X+Left_W, nW:=(Right_X-x)//2, nX:=x+nW, Last_X:=x
  }
  Return, OCR
}


/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(
  int mode, int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * text, int * s1, int * s0
  , int err1, int err0, int w1, int h1, int * allpos)
{
  int o, i, j, k, x, y, w, h, ok=0;
  int r, g, b, rr, gg, bb, e1, e0, len1, len0, max;
  w=sw-w1+1; h=sh-h1+1; k=sy*Stride+sx*4;
  // Generate Lookup Table
  o=len1=len0=0;
  for (y=0; y<h1; y++)
  {
    for (x=0; x<w1; x++)
    {
      j=y*Stride+x*4;
      if (text[o++]=='1')
        s1[len1++]=j;
      else
        s0[len0++]=j;
    }
  }
  max=len1>len0 ? len1 : len0;
  // Color Mode
  if (mode==0)
  {
    for (y=0; y<h; y++)
    {
      for (x=0; x<w; x++)
      {
        o=y*Stride+x*4+k; e1=err1; e0=err0;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
            if (r+g+b>n && (--e1)<0) goto NoMatch1;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb;
            if (r<0) r=-r; if (g<0) g=-g; if (b<0) b=-b;
            if (r+g+b<=n && (--e0)<0) goto NoMatch1;
          }
        }
        allpos[ok++]=(sy+y)<<16|(sx+x);
        if (ok>=1024) goto Return1;
        NoMatch1:
        continue;
      }
    }
    goto Return1;
  }
  // Gray Threshold Mode
  c=(c+1)*1000;
  for (y=0; y<sh; y++)
  {
    for (x=0; x<sw; x++)
    {
      o=y*Stride+x*4+k;
      Bmp[3+o]=Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c ? 1:0;
    }
  }
  k=k+3;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      o=y*Stride+x*4+k; e1=err1; e0=err0;
      for (i=0; i<max; i++)
      {
        if (i<len1 && Bmp[o+s1[i]]!=1 && (--e1)<0) goto NoMatch2;
        if (i<len0 && Bmp[o+s0[i]]!=0 && (--e0)<0) goto NoMatch2;
      }
      allpos[ok++]=(sy+y)<<16|(sx+x);
      if (ok>=1024) goto Return1;
      NoMatch2:
      continue;
    }
  }
  Return1:
  return ok;
}

*/


; Note: This function is used for combination lookup,
; for example, a 0-9 text library has been set up,
; then any ID number can be found.
; Use Pic(Text,1) and PicN(number) when using.
; Use PicX(Text) to automatically cut into multiple characters. 
; Only grayscale threshold mode is currently supported.

FindText2(x,y,w,h,err1,err0,text,Interval=20)
{
  xywh2xywh(x-w,y-h,2*w+1,2*h+1,x,y,w,h)
  if (w<1 or h<1)
    return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits)
  ;--------------------------------------
  sx:=0, sy:=0, sw:=w, sh:=h
  arr:=[], info:=[], allw:=0, allv:=allcolor:=allcomment:=""
  if (err1=0 and err0=0)
    err1:=err0:=0.1
  Loop, Parse, text, |
  {
    v:=A_LoopField
    IfNotInString, v, $, Continue
    comment:="", e1:=err1, e0:=err0
    ; You Can Add Comment Text within The <>
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), comment:=Trim(r1)
    ; You can Add two fault-tolerant in the [], separated by commas
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r1.=","
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    StringSplit, r, v, $
    color:=r1, v:=r2
    if !InStr(color,"*")
      Continue
    StringSplit, r, v, .
    w1:=r1, v:=base64tobit(r2), h1:=StrLen(v)//w1
    if (r0<2 or h1<1 or w1>sw or h1>sh or StrLen(v)!=w1*h1)
      Continue
    if (allcolor="")
      allcolor:=StrReplace(color,"*")
    StrReplace(v,"1","",len1), len0:=StrLen(v)-len1
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    info.Push(StrLen(allv),w1,h1,len1,len0,e1,e0)
    allv.=v, allw+=w1, allcomment.=comment
  }
  if (allv="")
  {
    SetBatchLines, %bch%
    return, 0
  }
  num:=info.MaxIndex(), VarSetCapacity(in,num*4,0)
  Loop, % num
    NumPut(info[A_Index], in, 4*(A_Index-1), "int")
  VarSetCapacity(ss, sw*sh, 0), k:=StrLen(allv)*4
  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
  VarSetCapacity(allpos, 1024*4, 0)
  offsetX:=Interval, offsetY:=5
  if (ok:=PicFind2(allcolor,offsetX,offsetY,Scan0,Stride
    ,sx,sy,sw,sh,ss,allv,s1,s0,in,num,allpos))
  {
    Loop, % ok
      pos:=NumGet(allpos, 4*(A_Index-1), "uint")
      , rx:=(pos&0xFFFF)+x, ry:=(pos>>16)+y
      , arr.Push( [rx,ry,allw,h1,allcomment] )
  }
  SetBatchLines, %bch%
  return, arr.MaxIndex() ? arr:0
}

PicFind2(color, offsetX, offsetY
  , Scan0, Stride, sx, sy, sw, sh
  , ByRef ss, ByRef text, ByRef s1, ByRef s0
  , ByRef in, num, ByRef allpos)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5557565383EC708BBC24BC0000008BAC24B4000000C7442"
    . "4140000000085FF0F8EBD0000008B4424148B9C24B80000008"
    . "BB424B80000008B5C83048B3486895C24048B9C24B80000008"
    . "B44830885C0894424107E7789F28974240831FFC7042400000"
    . "0008B44240485C07E4C8B4C24088D1C38897C240C89F829F90"
    . "38C24AC000000EB0E8944950083C00183C20139C3741A803C0"
    . "13175EC8BBC24B00000008904B783C00183C60139C375E68B5"
    . "C2404015C24088B7C240C8304240103BC24A00000008B04243"
    . "9442410759883442414078B442414398424BC0000000F8F43F"
    . "FFFFF8B8424840000008BB42498000000C7042400000000C74"
    . "424040000000083C00169C0E803000089C38B84249C0000000"
    . "FAF8424940000008D14B08B8424A00000008BB42494000000F"
    . "7D88D04868BB424A4000000894424088B8424A0000000C1E00"
    . "285F68944240C0F8E9700000089AC24B400000089DF89D58B8"
    . "C24A000000085C97E628B8C24900000008B5C24048BB424900"
    . "00000039C24A800000001E9036C240C01EE89F68DBC2700000"
    . "0000FB651020FB6410169D22B01000069C04B02000001C20FB"
    . "6016BC07201D039C70F9F0383C10483C30139CE75D38BB424A"
    . "00000000174240483042401036C24088B0424398424A400000"
    . "00F857BFFFFFF8BAC24B40000008B9424B80000008BB424B80"
    . "000008B8424B8000000C744241C00000000C74424580000000"
    . "0C744246C000000008B52148B760C8B4004895424248B9424B"
    . "800000089F3897424208BB424B80000008B52188B761089542"
    . "4288B9424A000000089342429C239F30F4DF383E8018954241"
    . "889F38BB424B80000008944245C8B8424A40000002B4608894"
    . "424640F881F03000089AC24B400000089DD8B44241885C00F8"
    . "8D30000008B7424588B84249C000000C74424080000000001F"
    . "0C1E0108944246889F02BB4248C00000089F3BE000000000F4"
    . "9F3897424540FAFB424A0000000897424508BB4248C0000000"
    . "1C6897424608DB426000000008B54241C0354240885ED0F8EA"
    . "00000008B7424288B4C242431C0039424A80000008B5C24208"
    . "9742404EB2C908D7426003904247E1B8BB424B40000008B3C8"
    . "601D7803F00740A836C24040178248D760083C00139C574593"
    . "9C37ED58BB424B00000008B3C8601D7803F0174C483E90179B"
    . "F83442408018B442408394424187D8083442458018B9C24A00"
    . "000008B442458015C241C394424640F8D03FFFFFF8B54246C8"
    . "3C47089D05B5E5F5DC2400066908B44245C0344240883BC24B"
    . "C000000078944242C0F8EA50100008B8424B8000000C744244"
    . "007000000896C244883C020894424308B4424308B9424A0000"
    . "0008B74242C8B0029C2894424448B84248800000001F039C20"
    . "F4EC289C38944244C39F30F8C060100008B4424308B5C24608"
    . "B700C8B68088974240C8B70108974241489C68B40148944243"
    . "88B8424A40000002B460439C30F4EC3894424108B46FC8BB42"
    . "4B000000089442404C1E00201C6038424B40000008944243C8"
    . "B4424548B7C242C037C24503B442410894424040F8F8600000"
    . "085ED7E258B9C24A80000008B54241431C001FB8B0C8601D98"
    . "03901740583EA01784A83C00139C575EA8B54240C85D20F8E8"
    . "70000008B9C24A8000000896C243431C08B4C24388B6C243C0"
    . "1FBEB0983C0013944240C74658B54850001DA803A0074EC83E"
    . "90179E78B6C243490834424040103BC24A00000008B4424043"
    . "94424100F8D7AFFFFFF8344242C018B44242C3944244C0F8D4"
    . "DFFFFFF83442408018B6C24488B442408394424180F8DCCFDF"
    . "FFFE947FEFFFF8DB426000000008B74242C8B4424448344244"
    . "007834424301C8D4430FF8944242C8B442440398424BC00000"
    . "00F8F79FEFFFF8B6C24488B74246C8B4424080384249800000"
    . "08B9C24C00000000B4424688D560181FAFF0300008904B30F8"
    . "F07FEFFFF83442408018954246C8B442408394424180F8D4EF"
    . "DFFFFE9C9FDFFFF83C47031D25B89D05E5F5DC240009090"
    x64:="4157415641554154555756534883EC78488B84242801000"
    . "0488BAC2408010000898C24C00000008B8C243001000089942"
    . "4C800000044898424D00000004C898C24D80000004C8BBC241"
    . "001000085C94C8BA42418010000488BBC24200100004889042"
    . "4C7442408000000000F8EA4000000448BB424F80000004889A"
    . "C2408010000488B0424448B6808448B108B70044585ED7E5E4"
    . "489D14489D54531DB31DB9085F67E434863D5468D0C1E4489D"
    . "84C01FAEB164C63C14883C20183C1014289048783C0014139C"
    . "1741C803A3175E54D63C24883C2014183C2014389048483C00"
    . "14139C175E401F583C3014501F34139DD75AE8344240807488"
    . "304241C8B442408398424300100000F8F74FFFFFF488BAC240"
    . "80100008B8424C00000008B9C24E80000004531F68B9424000"
    . "10000448D50018B8424F00000000FAF8424E00000004569D2E"
    . "8030000448D1C988B8424F80000008B9C24E0000000F7D8448"
    . "D3C838B8424F800000031DB85D2448D2C85000000000F8E900"
    . "000004C89A424180100004889BC24200100008BB424F800000"
    . "0448BA42400010000488BBC24D800000085F67E494963C34C6"
    . "3CB4531C0488D4C07024901E90FB6110FB641FF69D22B01000"
    . "069C04B02000001C20FB641FE6BC07201D04139C2430F9F040"
    . "14983C0014883C1044439C67FCD4501EB01F34183C6014501F"
    . "B4539F475A74C8BA42418010000488BBC2420010000488B9C2"
    . "428010000488B842428010000C744240C0000000048C744245"
    . "000000000C744246C00000000448B6B0C448B73108B5B148B4"
    . "0044589F7895C2410488B9C24280100008B5B18895C24148B9"
    . "C24F800000029C34539F5891C24488B9C2428010000450F4DF"
    . "D83E8018944245C8B8424000100002B4308894424644489F84"
    . "589EF4189C50F88100300008B042485C00F88D7000000488B5"
    . "C24508B8424F00000004889BC24200100004489EF01D8C1E01"
    . "08944246889D82B8424D000000089C6B8000000000F49C631F"
    . "6894424584989F5488BB424200100000FAF8424F8000000894"
    . "4244C8B8424D000000001D8894424600F1F40008B44240C85F"
    . "F44896C2408468D0C280F8E9B000000448B542414448B44241"
    . "031C0EB254139CE7E188B14864401CA4863D2807C150000740"
    . "84183EA01782866904883C00139C77E684139C789C17ED4418"
    . "B14844401CA4863D2807C15000174C34183E80179BD4983C50"
    . "144392C247D904189FD4889F74883442450018BB424F800000"
    . "0488B4424500174240C394424640F8DFEFEFFFF8B4C246C89C"
    . "84883C4785B5E5F5D415C415D415E415FC30F1F008B44245C0"
    . "344240883BC2430010000070F8E99010000488B9C242801000"
    . "04C89642418448BA424F800000044897C24344889742420C74"
    . "4242C0700000089C64883C3204489742438897C243C4C896C2"
    . "4404989DF418B074489E229C2894424308B8424C800000001F"
    . "039C20F4EC239F0894424480F8CBD000000418B47148BBC240"
    . "0010000412B7F0449635FFC458B4F08458B6F0C894424288B4"
    . "42460458B771039F80F4EF8488B44241848C1E3024C8D14184"
    . "8035C24208B44244C448D04068B44245839F84189C37F630F1"
    . "F4400004585C97E234489F131D2418B04924401C04898807C0"
    . "50001740583E90178334883C2014139D17FE24585ED7E738B4"
    . "C242831D2EB094883C2014139D57E628B04934401C04898807"
    . "C05000074E883E90179E34183C3014501E04439DF7DA283C60"
    . "1397424487D814C8B6C2440448B7C2434448B7424388B7C243"
    . "C4C8B642418488B7424204983C50144392C240F8DEEFDFFFFE"
    . "959FEFFFF660F1F8400000000008B4424308344242C074983C"
    . "71C8D7430FF8B44242C398424300100000F8FC2FEFFFF448B7"
    . "C2434448B7424388B7C243C4C8B6C24404C8B642418488B742"
    . "420486344246C8B542408039424E8000000488B9C243801000"
    . "00B5424688D480181F9FF0300008914830F8F0DFEFFFF4983C"
    . "50144392C24894C246C0F8D61FDFFFFE9CCFDFFFF31C9E9EFF"
    . "DFFFF9090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  return, DllCall(&MyFunc, "int",color, "int",offsetX
    , "int",offsetY, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&ss, "AStr",text, "ptr",&s1, "ptr",&s0
    , "ptr",&in, "int",num, "ptr",&allpos)
}

/***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind2(
  int c, int offsetX, int offsetY
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , char * ss, char * text, int * s1, int * s0
  , int * in, int num, int * allpos )
{
  int o, x, y, i, j, max, e1, e0, ok=0;
  int o1, x1, y1, w1, h1, sx1, sy1, len1, len0, err1, err0;
  int o2, x2, y2, w2, h2, sx2, sy2, len21, len20, err21, err20;
  // Generate Lookup Table
  for (i=0; i<num; i+=7)
  {
    o=o1=o2=in[i]; w1=in[i+1]; h1=in[i+2];
    for (y=0; y<h1; y++)
    {
      for (x=0; x<w1; x++)
      {
        j=y*sw+x;
        if (text[o++]=='1')
          s1[o1++]=j;
        else
          s0[o2++]=j;
      }
    }
  }
  // Gray Threshold Mode
  c=(c+1)*1000; o=sy*Stride+sx*4; j=Stride-4*sw; i=0;
  for (y=0; y<sh; y++, o+=j)
  {
    for (x=0; x<sw; x++, o+=4, i++)
      ss[i]=Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c ? 1:0;
  }
  // Start Lookup
  w1=in[1]; h1=in[2]; len1=in[3]; len0=in[4]; err1=in[5]; err0=in[6];
  sx1=sw-w1; sy1=sh-h1; max=len1>len0 ? len1 : len0;
  for (y=0; y<=sy1; y++)
  {
    for (x=0; x<=sx1; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      for (j=0; j<max; j++)
      {
        if (j<len1 && ss[o+s1[j]]!=1 && (--e1)<0) goto NoMatch1;
        if (j<len0 && ss[o+s0[j]]!=0 && (--e0)<0) goto NoMatch1;
      }
      x1=x+w1-1; y1=y-offsetY; if (y1<0) y1=0;
      for (i=7; i<num; i+=7)
      {
        o2=in[i]; w2=in[i+1]; h2=in[i+2];
        len21=in[i+3]; len20=in[i+4]; err21=in[i+5]; err20=in[i+6];
        sx2=sw-w2; j=x1+offsetX; if (j<sx2) sx2=j;
        sy2=sh-h2; j=y+offsetY; if (j<sy2) sy2=j;
        for (x2=x1; x2<=sx2; x2++)
        {
          for (y2=y1; y2<=sy2; y2++)
          {
            o=y2*sw+x2; e1=err21; e0=err20;
            for (j=0; j<len21; j++)
              if (ss[o+s1[o2+j]]!=1 && (--e1)<0) goto NoMatch2;
            for (j=0; j<len20; j++)
              if (ss[o+s0[o2+j]]!=0 && (--e0)<0) goto NoMatch2;
            goto MatchOK;
            NoMatch2:
            continue;
          }
        }
        goto NoMatch1;
        MatchOK:
        x1=x2+w2-1;
      }
      allpos[ok++]=(sy+y)<<16|(sx+x);
      if (ok>=1024) goto Return1;
      NoMatch1:
      continue;
    }
  }
  Return1:
  return ok;
}

*/


;================= The End =================

;
