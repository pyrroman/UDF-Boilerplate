#include-once
#include<SendMessage.au3>

; ================================================================================================================================
;
; Title          : _TaskBar
; Author         : MDiesel
; Description    : Creation, and control, of your own taskbar item!!
;
;
; Function List:
;     * _TaskBarItemCreate
;     * _TaskBarItemSetUpSync
;     * _TaskBarItemRemoveSync
;     * _TaskBarItemDestroy
;     * _TaskBarItemSetState
;     * _TaskBarItemSetStyle
;     * _TaskBarItemGetState
;     * _TaskBarItemGetStyle
;     * _TaskBarItemSetText
;     * _TaskBarItemGetText
;     * _TaskBarItemSetIcon
;     * _TaskBarItemSwitch
;
;     * _TaskBarGetHandle
;     * _TaskBarGetPos
;     * _TaskBarGetSide
;     * _TaskBarSetState
;     * _TaskBarGetState
;     * _TaskBarSetTrans
;     * _TaskBarSetStartState
;     * _TaskBarGetStartState
;     * _TaskBarSetClockState
;     * _TaskBarGetClockState
;     * _TaskBarSetStartMenuState
;     * _TaskBarGetStartMenuState
;
; Internal:
;     * __TaskBarEvent
;     * __TaskBarEventMaximize
;     * __TaskBarDebugPrint
;     * __TaskBarDebugMode
;
; ================================================================================================================================

; { VARS }========================================================================================================================

Global $hLastUsedTabItem = 0
Global $bTaskBarDebug = False

; States
Global Const $TASKSTATE_SHOW = 1
Global Const $TASKSTATE_HIDE = 2
Global Const $TASKSTATE_ACTIVE = 4
Global Const $TASKSTATE_NONACTIVE = 8

; Styles
Global Const $TSKS_NONE = 0
Global Const $TSKS_MAXIMIZE = 1
Global Const $TSKS_MINIMIZE = 2
Global Const $TSKS_SIZE = 4
Global Const $TSKS_DEFAULT = 8
Global Const $TSKS_ALL = 15

Global Const $sTaskBarTitle = "[class:Shell_TrayWnd]"

; ================================================================================================================================

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemCreate
; Description  : Creates a custom Taskbar item, that can be edited and handled.
; Syntax       : _TaskBarItemCreate ($sText [, $sIconFile, $nIcon [, $nInitState]])
; Variables    : $sText -       The text to be shown on the taskbar item.
;                $sIconFile -   The icon file directory
;                $nIcon -       The ordinal value of the icon to retrieve
;                $nStyle -      The initial style, see _TaskBarItemSetStyle for values.
;                $nInitState -  The initial state of the item. See _TaskBarItemSetState for values.
; Returns      : Success -      Returns the handle to the new item.
;                Failure -      Returns -1
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemDestroy, _TaskBarItemSet...
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemCreate($sText, $sIconFile = "", $nIcon = 0, $nStyle = 8, $nInitState = 1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemCreate (" & $sText & ")")
	$hCur = GUISwitch(-1)
	$hRet = GUICreate($sText, 100, 100, @DesktopWidth + 100, @DesktopHeight + 100, -1, -1)
	If $sIconFile <> "" Then GUISetIcon($sIconFile, $nIcon, $hRet)
	WinSetTrans($hRet, "", 0)
	_TaskBarItemSetState($nInitState, $hRet)
	_TaskBarItemSetOptions($nStyle, $hRet)
	GUISwitch($hCur)
	$hLastUsedTabItem = $hRet
	Return $hRet
EndFunc   ;==>_TaskBarItemCreate

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemSetupSync
; Description  : Associates the Taskbar item with a window, so they act in the same way.
; Syntax       : _TaskBarItemSetUpSync ($hWnd [, $hTaskItem])
; Variables    : $hWnd -        The window to be associated. I recommend only using your own GUI's.
;                $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        : Unsure if this will work on all windows, as it registers various windows messages, which could already be in use.
;                It also uses most of the internal functions in this udf.
; Related      : _TaskBarItemRemoveSync
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemSetUpSync($hWnd, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetupSync. (" & $hWnd & " : " & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	$hCur = WinGetHandle(-1)
	Global $hTaskBarSyncTaskItem = $hTaskItem
	Global $hTaskbarSyncItem = $hWnd
	GUISwitch($hWnd)
	GUIRegisterMsg(0x0006, "__TaskBarEvent")
	GUIRegisterMsg(0x0112, "__TaskBarEvent")
	GUISwitch($hTaskItem)
	GUIRegisterMsg(0x0006, "__TaskBarEvent")
	GUIRegisterMsg(0x0112, "__TaskBarEvent")
	GUISwitch($hCur)
	_TaskBarItemSetStyle(_TaskBarItemGetStyle($hWnd), $hTaskItem) ; sync styles.
	Return 1
EndFunc   ;==>_TaskBarItemSetUpSync

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemRemoveSync
; Description  : Removes all windows messages associating a window with the taskbar item.
; Syntax       : _TaskBarItemRemoveSync ($hWnd [, $hTaskItem])
; Variables    : $hWnd -        The window to be associated. I recommend only using your own GUI's.
;                $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemSetUpSync
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemRemoveSync($hWnd, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemRemoveSync. (" & $hWnd & " : " & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	$hCur = WinGetHandle(-1)
	$hTaskBarSyncTaskItem = 0
	$hTaskbarSyncItem = 0
	GUISwitch($hWnd)
	GUIRegisterMsg(0x0006, "")
	GUIRegisterMsg(0x0112, "")
	GUISwitch($hTaskItem)
	GUIRegisterMsg(0x0006, "")
	GUIRegisterMsg(0x0112, "")
	GUISwitch($hCur)
	Return 1
EndFunc   ;==>_TaskBarItemRemoveSync

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemDestroy
; Description  : Destroys a previously created taskbar item
; Syntax       : _TaskBarItemRemoveSync ($hTaskItem)
; Variables    : $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemCreate
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemDestroy($hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemDestroy (" & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Return GUIDelete($hTaskItem)
EndFunc   ;==>_TaskBarItemDestroy

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemSetState
; Description  : Sets characteristics of the taskbar item. DOES NOT affect the associated window (if exists.)
; Syntax       : _TaskBarItemSetState ([$nState [, $hTaskItem]])
; Variables    : $nState -      The state to change to. Can be a combination of the following.
;                  $TASKSTATE_SHOW         - Shown           - 1
;                  $TASKSTATE_HIDE         - Hidden          - 2
;                  $TASKSTATE_MINIMIZED    - Minimised       - 4
;                  $TASKSTATE_NOTMINIMIZED - Not Minimized   - 8
;              : $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        : The last 2, active and non active, will affect any partner synced windows. The first 2 don't though
; Related      : _TaskBarItemGetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemSetState($nState = 1, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetState (" & $hTaskItem & " : " & $nState & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	If BitAND($nState, 1) Then
		GUISetState($hTaskItem, @SW_SHOW)
	ElseIf BitAND($nState, 2) Then
		GUISetState($hTaskItem, @SW_HIDE)
	ElseIf BitAND($nState, 4) Then
		GUISetState($hTaskItem, @SW_MINIMIZE)
	ElseIf BitAND($nState, 8) Then
		GUISetState($hTaskItem, @SW_RESTORE)
	Else
		Return SetError($nState, 0, 0)
	EndIf
	Return 1
EndFunc   ;==>_TaskBarItemSetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemGetState
; Description  : Gets characteristics of the taskbar item.
; Syntax       : _TaskBarItemGetState ([$hTaskItem [, $nState]])
; Variables    : $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
;                $nState -      If Defined, retrun is a bool answer to whether or not the state is used.
; Returns      : Success -      Returns The states of the taskbar item. If $nState != "" Then will return True/false
;                Failure -      Returns -1
; Author       : MDiesel
; Notes        : See _TaskBarItemSetState for values.
; Related      : _TaskBarItemSetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemGetState($hTaskItem = -1, $nState = "")
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemGetState (" & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Local $nRet = WinGetState($hTaskItem, "")
	If @error Or Not BitAND($nRet, 1) Then Return -1
	$nRet -= 1
	If BitAND($nRet, 2) Then ; Is visible
		$nRet += 1
	Else
		$nRet += 2
	EndIf
	If BitAND($nRet, 16) Then
		$nRet += 4
	Else
		$nRet += 8
	EndIf
	If $nState = "" Then Return $nRet
	If BitAND($nRet, $nState) Then Return True
	Return False
EndFunc   ;==>_TaskBarItemGetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemSetStyle
; Description  : Sets characteristics of the taskbar item. DOES NOT affect the associated window (if exists.)
; Syntax       : _TaskBarItemSetOptions ([$iOptions [, $hTaskItem]])
; Variables    : $iOptions -    The state to change to. Can be a combination of the following.
;                     $TSKS_NONE         =  0
;                     $TSKS_MAXIMIZE     =  1
;                     $TSKS_MINIMIZE     =  2
;                     $TSKS_SIZE         =  4
;                     $TSKS_DEFAULT      =  8 (defualt)
;                     $TSKS_ALL          = 15
;                $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        : If you want any menu to show you must include 8.
; Related      : _TaskBarItemGetStyle
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemSetStyle($iOptions = 8, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetStyle (" & $hTaskItem & ", " & $iOptions & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Local $iStyle = 0
	If BitAND($iOptions, 1) Then $iStyle += 0x00010000
	If BitAND($iOptions, 2) Then $iStyle += 0x00020000
	If BitAND($iOptions, 4) Then $iStyle += 0x00040000
	If BitAND($iOptions, 8) Then $iStyle += 0x00080000
	Return GUISetStyle($iStyle, 0, $hTaskItem)
EndFunc   ;==>_TaskBarItemSetStyle

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemGetStyle
; Description  : Gets the style for the taskbar item.
; Syntax       : _TaskBarItemGetOptions ([$hTaskItem])
; Variables    : $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : styles. See SetStyle for values.
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemSetStyle
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemGetStyle($hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemGetStyle (" & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Local $iOptions = GUIGetStyle($hTaskItem), $iStyle = 0
	If BitAND($iOptions, 0x00010000) Then $iStyle += 1
	If BitAND($iOptions, 0x00020000) Then $iStyle += 2
	If BitAND($iOptions, 0x00040000) Then $iStyle += 4
	If BitAND($iOptions, 0x00080000) Then $iStyle += 8
	Return $iStyle
EndFunc   ;==>_TaskBarItemGetStyle

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemSetText
; Description  : Sets the text of the taskbar item
; Syntax       : _TaskBarItemSetText ($sText [, $hTaskItem])
; Variables    : $sText -       The text to set
;                $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemGetText
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemSetText($sText, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetText (" & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	WinSetTitle($hTaskItem, "", $sText)
	If @error Then Return 0
	Return 1
EndFunc   ;==>_TaskBarItemSetText

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemGetText
; Description  : Gets the text of the taskbar item
; Syntax       : _TaskBarItemGetText ([$hTaskItem])
; Variables    : $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns the text
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemSetText
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemGetText($hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemGetText (" & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Return WinGetTitle($hTaskItem, "")
EndFunc   ;==>_TaskBarItemGetText

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemSetIcon
; Description  : Sets the icon for the taskbar item.
; Syntax       : _TaskBarItemSetIcon ($sIconFile, $nIconVal, [$hTaskItem])
; Variables    : $sIconFile -   The directory of the icon file or library
;                $nIconVal -    The ordinal value of the icon to retrieve
;                $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : Success -      Returns 1
;                Failure -      Returns 0
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemGetIcon
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemSetIcon($sIconFile, $nIconVal, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetIcon (" & $hTaskItem & " - " & $sIconFile & "," & $nIconVal & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Return GUISetIcon($sIconFile, $nIconVal, $hTaskItem)
EndFunc   ;==>_TaskBarItemSetIcon

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemFlash
; Description  : Flashes the taskbar item
; Syntax       : _TaskBarItemFlash ([$nFlashes [, $nDelay [, $hTaskItem]]])
; Variables    : $nFlashes -    The amount of times to flash (default is 4)
;                $nDelay -      The delay between Flashes (default 500ms)
;                $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : None
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarItemGetIcon
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemFlash($nFlashes = 4, $nDelay = 500, $hTaskItem = -1)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetIcon (" & $hTaskItem & ")")
	If $hTaskItem = -1 Then $hTaskItem = $hLastUsedTabItem
	Return WinFlash($hTaskItem, "", $nFlashes, $nDelay)
EndFunc   ;==>_TaskBarItemFlash

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarItemSwitch
; Description  : Switches the default handle for a taskbar item.
; Syntax       : _TaskBarItemSwitch ($hTaskItem)
; Variables    : $hTaskItem -   A handle to the task item from a previous call to _TaskBarItemCreate. Default is previous.
; Returns      : None
; Author       : MDiesel
; Notes        :
; Related      :
; Example      :
;
; ================================================================================================================================

Func _TaskBarItemSwitch($hTaskItem)
	If $bTaskBarDebug Then __TaskbarPrintDebug("_TaskBarItemSetIcon (" & $hTaskItem & ")")
	$hLastUsedTabItem = $hTaskItem
EndFunc   ;==>_TaskBarItemSwitch

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarGetHandle
; Description  : Returns the handle of the taskbar.
; Syntax       : _TaskBarGetHandle ([$nHType])
; Variables    : $nHType -      The type of handle to return. 0 = Handle (default), 1 = Class, 2 = title
; Returns      : An array where:
;                   0 = X pos
;                   1 = Y pos
;                   2 = Width
;                   3 = Height
; Author       : MDiesel
; Notes        :
; Related      :
; Example      :
;
; ================================================================================================================================

Func _TaskBarGetHandle($nHType = 0)
	If $nHType = 0 Then Return WinGetHandle($sTaskBarTitle, "")
	If $nHType = 1 Then Return "Shell_TrayWnd"
	If $nHType = 2 Then Return WinGetTitle($sTaskBarTitle, "")
EndFunc   ;==>_TaskBarGetHandle

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarGetPos
; Description  : Returns the position of the taskbar
; Syntax       : _TaskBarGetPos ([$nDim])
; Variables    : $nDim -        The dimension to return
; Returns      : If $nDim = 4 Then An array where:
;                   0 = X pos
;                   1 = Y pos
;                   2 = Width
;                   3 = Height
;                Else it will return that array dimension
; Author       : MDiesel
; Notes        :
; Related      :
; Example      :
;
; ================================================================================================================================

Func _TaskBarGetPos($nDim = 4)
	Local $aPos = WinGetPos($sTaskBarTitle, "")
	If $nDim = 4 Then Return $aPos
	Return $aPos[$nDim]
EndFunc   ;==>_TaskBarGetPos

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarGetSide
; Description  : Returns the side of the screen that the taskbar is docked to.
; Syntax       : _TaskBarGetSide ()
; Variables    : None
; Returns      : a string saying "left", "right", "top" or "bottom"
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarGetPos
; Example      :
;
; ================================================================================================================================

Func _TaskBarGetSide()
	Local $aPos = _TaskBarGetPos()
	If $aPos[0] < 10 Then
		If $aPos[1] < 10 Then
			If $aPos[2] > 400 Then Return "Top"
			Return "Left"
		EndIf
		Return "Bottom"
	EndIf
	Return "Right"
EndFunc   ;==>_TaskBarGetSide

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarSetState
; Description  : SetsWhether the taskbar is shown or hidden
; Syntax       : _TaskBarSetState ([$sState])
; Variables    : $sState -      The state, one of the standard @SW_ macros. default is @SW_SHOW
; Returns      : None
; Author       : MDiesel
; Notes        :
; Related      :
; Example      :
;
; ================================================================================================================================

Func _TaskBarSetState($sState = @SW_SHOW)
	Return WinSetState($sTaskBarTitle, "", $sState)
EndFunc   ;==>_TaskBarSetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarGetState
; Description  : Gets the state of the taskbar.
; Syntax       : _TaskBarGetState ()
; Variables    : None
; Returns      : The state of the taskbar
; Author       : MDiesel
; Notes        :
; Related      :
; Example      :
;
; ================================================================================================================================

Func _TaskBarGetState()
	Return WinGetState($sTaskBarTitle, "")
EndFunc   ;==>_TaskBarGetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarSetTrans
; Description  : Sets the taskbar transparency.
; Syntax       : _TaskBarSetTrans ([$nTrans])
; Variables    : $nTrans -      The transparency, between 0 and 255. default 255
; Returns      : Success -      non-zero
;                Failure -      0 and sets @Error to:
;                                   1 - OS not supported
;                                   2 - value out of range
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarSetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarSetTrans($nTrans = 255)
	If $nTrans < 0 Or $nTrans > 255 Then Return SetError(2, 0, 0)
	Return WinSetTrans($sTaskBarTitle, "", $nTrans)
EndFunc   ;==>_TaskBarSetTrans

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarStartSetState
; Description  : Sets the Start buttons state
; Syntax       : _TaskBarStartSetState ([$bState])
; Variables    : $sState -      True = Show (default)
;                               False = Hide
; Returns      : None
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarStartGetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarStartSetState($bState = True)
	If $bState Then Return ControlShow($sTaskBarTitle, "", "Button1")
	Return ControlHide($sTaskBarTitle, "", "Button1")
EndFunc   ;==>_TaskBarStartSetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarStartGetState
; Description  : Gets the Starts state
; Syntax       : _TaskBarStartGetState ()
; Variables    : None
; Returns      : The state of the Start button 1 = visible, 0 = hidden.
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarStartSetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarStartGetState()
	Return ControlCommand($sTaskBarTitle, "", "Button1", "IsVisible", "")
EndFunc   ;==>_TaskBarStartGetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarClockSetState
; Description  : Sets the Clocks state
; Syntax       : _TaskBarStartSetState ([$bState])
; Variables    : $bState -      True = Show (default)
;                               False = Hide
; Returns      : None
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarClockGetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarClockSetState($bState = True)
	If $bState Then Return ControlShow($sTaskBarTitle, "", "TrayClockWClass1")
	Return ControlHide($sTaskBarTitle, "", "TrayClockWClass1")
EndFunc   ;==>_TaskBarClockSetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarClockGetState
; Description  : Gets the Clocks state
; Syntax       : _TaskBarStartGetState ()
; Variables    : None
; Returns      : The state of the Clock 1 = visible, 0 = hidden.
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarClockSetState
; Example      :
;
; ================================================================================================================================

Func _TaskBarClockGetState()
	Return ControlCommand($sTaskBarTitle, "", "TrayClockWClass1", "IsVisible", "")
EndFunc   ;==>_TaskBarClockGetState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarSetStartMenuState
; Description  : Sets the state of the start menu.
; Syntax       : _TaskBarSetStartMenuState ([$nState])
; Variables    : $nState -    one of the @SW_... macros.
; Returns      : None
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarGetStartMenuState
; Example      :
;
; ================================================================================================================================

Func _TaskBarSetStartMenuState($nState = @SW_SHOW)
	WinSetState("[CLASS:DV2ControlHost]", "", $nState)
EndFunc   ;==>_TaskBarSetStartMenuState

; { FUNCTION }====================================================================================================================
;
; Name         : _TaskBarGetStartMenuState
; Description  : Gets the state of the start menu.
; Syntax       : _TaskBarGetStartMenuState ()
; Variables    : None
; Returns      : the state of the startmenu
; Author       : MDiesel
; Notes        :
; Related      : _TaskBarSetStartMenuState
; Example      :
;
; ================================================================================================================================

Func _TaskBarGetStartMenuState()
	Return WinGetState("[CLASS:DV2ControlHost]", "")
EndFunc   ;==>_TaskBarGetStartMenuState

; #INTERNAL_USE_ONLY#=============================================================================================================
;
; Name         : __TaskBarEventActivate
; Description  : The handler for the activation and deactivation of the winows.
; Syntax       : __TaskBarEventActivate ($hWnd, $msgID, $wParam, $lParam)
; Variables    : $hWnd -      The handle to the source window
;                $msgID -     The message id.
;                $wParam -    The low-order word specifies whether the window is being activated or deactivated
;                $lParam -    Handle to the window being activated or deactivated
; Returns      : Success -    $GUI_RUNDEFMSG
;                Failure -    0 and sets @Error to:
;                               1 - No sync setup.
; Author       : MDiesel
; Remarks      : Redirects any messages so that both of them handle the events.
; Related      :
;
; ================================================================================================================================

Func __TaskBarEvent($hWnd, $msgID, $wParam, $lParam)
	If $bTaskBarDebug Then __TaskbarPrintDebug("__TaskBarEvent ==> " & $msgID)
	If Not IsDeclared("hTaskBarSyncTaskItem") Then Return SetError(1, 0, 0)
	Switch $msgID
		Case 0xF010, 0xF060, 274, 6 ; move, close, non active, active
			If $hWnd = $hTaskBarSyncTaskItem Then _; Task item initiated.
					_SendMessage($hTaskbarSyncItem, $msgID, $wParam, $lParam)
		Case 0xF030 ; maximize
			If $hWnd = $hTaskBarSyncTaskItem Then _
					_SendMessage($hTaskBarSyncTaskItem, 0xF120, 0, 0) ; restore
	EndSwitch
EndFunc   ;==>__TaskBarEvent

; #INTERNAL_USE_ONLY#=============================================================================================================
;
; Name         : __TaskBarDebugPrint
; Description  : Used for debugging when creating examples
; Syntax       : __TaskBarDebugPrint ($sText [, $iLine])
; Variables    : $sText -     String to printed to console
;                $iLine -     Line number function was called from
; Returns      : None
; Author       : MDiesel
; Remarks      : For Internal Use Only
; Related      :
;
; ================================================================================================================================

Func __TaskBarDebugPrint($sText, $iLine = @ScriptLineNumber)
	ConsoleWrite( _
			"!===========================================================" & @LF & _
			"+======================================================" & @LF & _
			"-->Line(" & StringFormat("%04d", $iLine) & "):" & @TAB & $sText & @LF & _
			"+======================================================" & @LF)
EndFunc   ;==>__TaskBarDebugPrint

; #INTERNAL_USE_ONLY#=============================================================================================================
;
; Name         : __TaskBarDebugMode
; Description  : Set debugging on from within a script
; Syntax       : __TaskBarDebugMode ($bMode)
; Variables    : $bMode -     The mode to set to. can be True or False. -1 = Not current
; Returns      : None
; Author       : MDiesel
; Remarks      : For Internal Use Only
; Related      :
;
; ================================================================================================================================

Func __TaskBarDebugMode($bMode)
	If $bMode = -1 Then $bMode = Not $bMode
	$bTaskBarDebug = $bMode
EndFunc   ;==>__TaskBarDebugMode
