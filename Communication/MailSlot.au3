
; MailSlot.au3
;.......script written by trancexx (trancexx at yahoo dot com)

#cs
	Available functions:
	_MailSlotCheckForNextMessage
	_MailSlotClose
	_MailSlotCreate
	_MailSlotGetMessageCount
	_MailSlotGetTimeout
	_MailSlotSetTimeout
	_MailSlotRead
	_MailSlotWrite
#ce

; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotCheckForNextMessage
; Description ...: Checks for presence of a new message.
; Syntax.........: _MailSlotCheckForNextMessage ($hMailSlot)
; Parameters ....: $hMailSlot - Mailslot handle
; Return values .: Success - Returns 0 if there is no message or the size of a new message in bytes if there is one
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - GetMailslotInfo function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365435(VS.85).aspx
;
;==========================================================================================
Func _MailSlotCheckForNextMessage($hMailSlot)

	Local $aCall = DllCall("kernel32.dll", "int", "GetMailslotInfo", _
			"ptr", $hMailSlot, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	If $aCall[3] = -1 Or Not $aCall[4] Then
		Return 0
	Else
		Return $aCall[3]
	EndIf

EndFunc   ;==>_MailSlotCheckForNextMessage


; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotClose
; Description ...: Closes mailslot.
; Syntax.........: _MailSlotClose ($hMailSlot)
; Parameters ....: $hMailSlot - Mailslot handle
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - CloseHandle function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/ms724211(VS.85).aspx
;
;==========================================================================================
Func _MailSlotClose($hMailSlot)

	Local $aCall = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hMailSlot)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return 1

EndFunc   ;==>_MailSlotClose


; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotCreate
; Description ...: Creates a mailslot with the specified name.
; Syntax.........: _MailSlotCreate ($sMailSlotName [,$iSize [, $iTimeOut [, $pSecurityAttributes])
; Parameters ....: $sMailSlotName - The name of the mailslot
;                  $iSize - The maximum size of a single message that can be written to the mailslot, in bytes. 0 means any size.
;                  $iTimeOut - The time a read operation can wait for a message to be written to the mailslot before a time-out occurs, in milliseconds.
;                              Can be 0 - returns immediately if no message is present
;                                     -1 (minus one) - waits forever for a message
;                  $pSecurityAttributes - A pointer to a SECURITY_ATTRIBUTES structure. 0 means the handle cannot be inherited.
; Return values .: Success - Returns a handle that a mailslot server can use to perform operations on the mailslot
;                          - Sets @error to 0
;                  Failure - Returns -1 and sets @error:
;                  |1 - CreateMailslotW function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Remarks .......: Mailslot name must have the following form and must be unique: \\.\mailslot\[path]name
;                  The name may include multiple levels of pseudo directories separated by backslashes.
;                  For example \\.\mailslot\abc\def\ghi is valid name too.
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365147(VS.85).aspx
;
;==========================================================================================
Func _MailSlotCreate($sMailSlotName, $iSize = 0, $iTimeOut = 0, $pSecurityAttributes = 0)

	Local $aCall = DllCall("kernel32.dll", "ptr", "CreateMailslotW", _
			"wstr", $sMailSlotName, _
			"dword", $iSize, _
			"dword", $iTimeOut, _
			"ptr", $pSecurityAttributes)

	If @error Or $aCall[0] = -1 Then
		Return SetError(1, 0, -1)
	EndIf

	Return $aCall[0]

EndFunc   ;==>_MailSlotCreate


; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotGetMessageCount
; Description ...: Retrieves the number of messages in the mailslot.
; Syntax.........: _MailSlotGetMessageCount ($hMailSlot)
; Parameters ....: $hMailSlot - Mailslot handle
; Return values .: Success - Returns the number of the messages in the mailslot waiting to be read.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - GetMailslotInfo function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365435(VS.85).aspx
;
;==========================================================================================
Func _MailSlotGetMessageCount($hMailSlot)

	Local $aCall = DllCall("kernel32.dll", "int", "GetMailslotInfo", _
			"ptr", $hMailSlot, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	If $aCall[3] = -1 Then
		Return 0
	Else
		Return $aCall[4]
	EndIf

EndFunc   ;==>_MailSlotGetMessageCount


; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotGetTimeout
; Description ...: Gets the time-out value used by the specified mailslot for a read operation.
; Syntax.........: _MailSlotGetTimeout ($hMailSlot)
; Parameters ....: $hMailSlot - Mailslot handle
; Return values .: Success - Returns integer value representing the time a read operation can wait for a message to be written to the mailslot before a time-out occurs, in milliseconds.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - GetMailslotInfo function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365435(VS.85).aspx
;
;==========================================================================================
Func _MailSlotGetTimeout($hMailSlot)

	Local $aCall = DllCall("kernel32.dll", "int", "GetMailslotInfo", _
			"ptr", $hMailSlot, _
			"dword*", 0, _
			"dword*", 0, _
			"dword*", 0, _
			"int*", 0)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return $aCall[5]

EndFunc   ;==>_MailSlotGetTimeout



; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotSetTimeout
; Description ...: Sets the time-out value used by the specified mailslot for a read operation.
; Syntax.........: _MailSlotSetTimeout ($hMailSlot, $iTimeout)
; Parameters ....: $hMailSlot - Mailslot handle
;                  $iTimeout - The time a read operation can wait for a message to be written to the mailslot before a time-out occurs, in milliseconds.
;                              -1 (minus one) means for function to wait forever for a message.
;                              0 (zero) mans to return immediately if no message is present
; Return values .: Success - Returns 1.
;                          - Sets @error to 0
;                  Failure - Returns 0 and sets @error:
;                  |1 - SetMailslotInfo function or call to it failed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365786(VS.85).aspx
;
;==========================================================================================
Func _MailSlotSetTimeout($hMailSlot, $iTimeOut)

	Local $aCall = DllCall("kernel32.dll", "int", "SetMailslotInfo", _
			"ptr", $hMailSlot, _
			"dword", $iTimeOut)

	If @error Or Not $aCall[0] Then
		Return SetError(1, 0, 0)
	EndIf

	Return 1

EndFunc   ;==>_MailSlotSetTimeout


; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotRead
; Description ...: Reads messages from the specified mailslot.
; Syntax.........: _MailSlotRead ($hMailSlot , $iSize [, $iMode])
; Parameters ....: $hMailSlot - Mailslot handle
;                  $iSize - The number of bytes to read.
;                  $iMode - Reading mode.
;                             Can be: 0 - read binary
;                                     1 - read ANSI
;                                     2 - read UTF8
; Return values .: Success - Returns read data
;                          - Sets @extended to number of read bytes
;                          - Sets @error to 0
;                  Special: Sets @error to -1 if specified buffer to read to is too small.
;                  Failure - Returns empty string and sets @error:
;                  |1 - DllCall() to ReadFile failed.
;                  |2 - GetLastError function or call to it failed.
;                  |3 - ReadFile function failed. @extended will be set to the return value of the GetLastError function.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa365467(VS.85).aspx
;                  http://msdn.microsoft.com/en-us/library/ms679360(VS.85).aspx
;
;==========================================================================================
Func _MailSlotRead($hMailSlot, $iSize, $iMode = 0)

	Local $tDataBuffer = DllStructCreate("byte[" & $iSize & "]")

	Local $aCall = DllCall("kernel32.dll", "int", "ReadFile", _
			"ptr", $hMailSlot, _
			"ptr", DllStructGetPtr($tDataBuffer), _
			"dword", $iSize, _
			"dword*", 0, _
			"ptr", 0)

	If @error Then
		Return SetError(1, 0, "")
	EndIf

	If Not $aCall[0] Then
		Local $aLastErrorCall = DllCall("kernel32.dll", "int", "GetLastError")
		If @error Then
			Return SetError(2, 0, "")
		EndIf
		If $aLastErrorCall[0] = 122 Then ; ERROR_INSUFFICIENT_BUFFER
			Return SetError(-1, 0, "")
		Else
			Return SetError(3, $aLastErrorCall[0], "")
		EndIf
	EndIf

	Local $vOut

	Switch $iMode
		Case 1
			$vOut = BinaryToString(DllStructGetData($tDataBuffer, 1))
		Case 2
			$vOut = BinaryToString(DllStructGetData($tDataBuffer, 1), 4)
		Case Else
			$vOut = DllStructGetData($tDataBuffer, 1)
	EndSwitch

	Return SetError(0, $aCall[4], $vOut)

EndFunc   ;==>_MailSlotRead


; #FUNCTION# ;===============================================================================
;
; Name...........: _MailSlotWrite
; Description ...: Writes message to the specified mailslot.
; Syntax.........: _MailSlotWrite ($sMailSlotName , $vData [, $iMode])
; Parameters ....: $hMailSlot - Mailslot name
;                  $vData - Data to write.
;                  $iMode - Writing mode.
;                             Can be: 0 - write binary
;                                     1 - write ANSI
;                                     2 - write UTF8
; Return values .: Success - Returns the number of written bytes
;                          - Sets @error to 0
;                  Failure - Returns empty string and sets @error:
;                  |1 - CreateFileW function or call to it failed.
;                  |2 - WriteFile function or call to it failed.
;                  |3 - Opened mail slot handle could not be closed.
;                  |4 - WriteFile function or call to it failed and additionally opened mail slot handle could not be closed.
; Author ........: trancexx
; Modified.......:
; Link ..........; http://msdn.microsoft.com/en-us/library/aa363858(VS.85).aspx
;                  http://msdn.microsoft.com/en-us/library/aa365747(VS.85).aspx
;                  http://msdn.microsoft.com/en-us/library/ms724211(VS.85).aspx
;
;==========================================================================================
Func _MailSlotWrite($sMailSlotName, $vData, $iMode = 0)

	Local $aCall = DllCall("kernel32.dll", "ptr", "CreateFileW", _
			"wstr", $sMailSlotName, _
			"dword", 0x40000000, _ ; GENERIC_WRITE
			"dword", 1, _ ; FILE_SHARE_READ
			"ptr", 0, _
			"dword", 3, _ ; OPEN_EXISTING
			"dword", 0, _ ; SECURITY_ANONYMOUS
			"ptr", 0)

	If @error Or $aCall[0] = -1 Then
		Return SetError(1, 0, 0)
	EndIf

	Local $hMailSlotHandle = $aCall[0]

	Local $bData

	Switch $iMode
		Case 1
			$bData = StringToBinary($vData, 1)
		Case 2
			$bData = StringToBinary($vData, 4)
		Case Else
			$bData = $vData
	EndSwitch

	Local $iBufferSize = BinaryLen($bData)

	Local $tDataBuffer = DllStructCreate("byte[" & $iBufferSize & "]")
	DllStructSetData($tDataBuffer, 1, $bData)

	$aCall = DllCall("kernel32.dll", "int", "WriteFile", _
			"ptr", $hMailSlotHandle, _
			"ptr", DllStructGetPtr($tDataBuffer), _
			"dword", $iBufferSize, _
			"dword*", 0, _
			"ptr", 0)

	If @error Or Not $aCall[0] Then
		$aCall = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hMailSlotHandle)
		If @error Or Not $aCall[0] Then
			Return SetError(4, 0, 0)
		EndIf
		Return SetError(2, 0, 0)
	EndIf

	Local $iOut = $aCall[4]

	$aCall = DllCall("kernel32.dll", "int", "CloseHandle", "ptr", $hMailSlotHandle)
	If @error Or Not $aCall[0] Then
		Return SetError(3, 0, $iOut)
	EndIf

	Return $iOut

EndFunc   ;==>_MailSlotWrite
