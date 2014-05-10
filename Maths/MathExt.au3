#include-once

; #INDEX# ========================================================================================================================
; Title .........: MathsExt
; Version .......: 1.0
; Description ...: A collection of more advanced maths functions
; AutoIt Version : 3.3.0.0+
; Language ......: English
; ================================================================================================================================

; #CURRENT# ======================================================================================================================
; BigInt Functions:
;     >> _BigIntCreate
;     >> _BigIntInitialize
;     >> _BigIntToString
;     >> _BigIntToSci
;     >> _BigIntCheck
;     >> _BigIntSetSign
;     >> _BigIntGetSign
;     >> _BigIntAdd
;     >> _BigIntMinus
;     >> _BigIntMultiply
;     >> _BigIntdivide              #NOT_WORKING#
;     >> _BigIntMax
;     >> _BigIntMin
;     >> _BigIntEqual
;     >> _BigIntRemoveTrailingZeros
;     >> _BigIntSetLength
;     >> _BigIntGetLength
;     >> _BigIntSetEqualLengths
; Fibonacci Functions
;     >> _MathFibonacciGet
;     >> _MathFibonacciCheck
;     >> _MathFibonacciGetIndex
;     >> _MathFibonacciGetSequence
; Trigonometry Functions
;     >> _MathRad
;     >> _MathDeg
;     >> _MathSin
;     >> _MathCos
;     >> _MathTan
;     >> _MathArcSin
;     >> _MathArcCos
;     >> _MathArcTan
; Miscellaneus Functions
;     >> _MathRoot
;     >> _MathRound
;     >> _MathQuadratic
; Pascal
;     >> _PascalGetLine
; ================================================================================================================================

; #VARIABLES# ====================================================================================================================
;
; type
   Global Const $RND_TYPE_DEFAULT     = Default ;  Decimal Places
   Global Const $RND_TYPE_DP          = 1       ;  Decimal Places        : 1.75643 to 3 dp = 1.756
   Global Const $RND_TYPE_SF          = 2       ;  Significant figures   : 1.75643 to 3 sf = 1.76
   Global Const $RND_TYPE_D           = 3       ;  Digits (same as sf, only 0 is significant)
;
; Direction
   Global Const $RND_DIR_DEFAULT      = Default ;  Nearest
   Global Const $RND_DIR_NEAREST      = 1       ;  Nearest                : 0.75 = 1
   Global Const $RND_DIR_UP           = 2       ;  Ceiling                : 0.75 = 1, -0.75 = 0
   Global Const $RND_DIR_DOWN         = 3       ;  Floor                  : 0.75 = 0, -0.75 = -1
   Global Const $RND_DIR_TOZERO       = 4       ;  Truncate               : 0.75 = 0, -0.75 = 0
   Global Const $RND_DIR_FROMZERO     = 5       ;  Not Truncate           : 0.75 = 1, -0.75 = -1
   Global Const $RND_DIR_DITHER       = 6       ;  Chance depending on fraction
;
; Tie Break Method
   Global Const $RND_TIE_DEFAULT      = Default ;  Not Truncate
   Global Const $RND_TIE_UP           = 1       ;  Up
   Global Const $RND_TIE_DOWN         = 2       ;  Down
   Global Const $RND_TIE_TOZERO       = 3       ;  Truncate
   Global Const $RND_TIE_FROMZERO     = 4       ;  Not Truncate
   Global Const $RND_TIE_EVEN         = 5       ;  To the nearest even
   Global Const $RND_TIE_ODD          = 6       ;  To the nearest odd
   Global Const $RND_TIE_STOCHASTIC   = 7       ;  Even chance of up or down
   Global Const $RND_TIE_ALTERNATIVE  = 8       ;  First UP then DOWN
;
; Padding
   Global Const $RND__Pad_DEFAULT      = Default ;  No
   Global Const $RND__Pad_YES          = 1       ;  2.83 to 3dp = 2.830
   Global Const $RND__Pad_NO           = 0       ;  2.83 to 3dp = 2.83
;
; Special
   Global Const $RND_PLACES_DEFAULT   = Default
   Global       $RND_TIE_ALT_CUR      = 0       ;  For The alternative tie break method ( ===== INTERNAL USE ONLY ====== )
;
; ================================================================================================================================

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntCreate
; Description ...: Creates a big int from an integer.
; Syntax.........: _BigIntCreate ($rawInt)
; Parameters ....: $rawInt         - The integer to be the initial value
; Return values .: Success         - The BigInt array
;                  Failure         - Returns 0,@Error =
;                                  |1 - $reawInt is not an integer.
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntCreate ($rawInt)
   If Not IsInt ($rawInt) Then Return SetError (1, 0, 0)

   ; Create array
   Local $strArray = StringSplit (String (Abs ($rawInt)), ""), $bigInt[$strArray[0] + 1]

   ; Apply Sign
   $bigInt[0] = "-"
   If $rawInt > 0 Then $bigInt[0] = "+"

   ; Fill Array
   For $i = 1 To $strArray[0]
      $bigInt[$strArray[0] - $i + 1] = $strArray[$i] + 0
   Next

   Return _BigIntRemoveTrailingZeros ($bigInt)
EndFunc ; ==> _BigIntCreate

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntInitialize
; Description ...: Sets up a big int for use from an existing array
; Syntax.........: _BigIntInitialize (ByRef $bigInt)
; Parameters ....: $bigInt         - The existing array
; Return values .: Success         - The BigInt array
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is not an array
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntInitialize (ByRef $bigInt)
   If IsArray ($bigInt) = 0 Then Return SetError (1, 0, 0)

   $bigInt[0]="+"
   For $i = 1 To UBound ($bigInt) - 1
      $bigInt[$i] = 0
   Next
   Return 1
EndFunc ; ==> _BigIntInitialize

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntToString
; Description ...: Converts a BigInt array to a string.
; Syntax.........: _BigIntToString ($bigInt [, $nKeepSign] )
; Parameters ....: $bigInt         - The existing array
;                  $nKeepSign      - If 1, a plus sign will show if positive (default 0 does not add a sign for positive)
; Return values .: Success         - The BigInt array
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is invalid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntToString ($bigInt, $nKeepSign = 0)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)

   ; Create String
   Local $ret = ""
   If $nKeepSign = 1 then $ret = "+"
   If $bigInt[0] = "-" Then $ret = "-"
   For $i = UBound ($bigInt) - 1 To 1 Step - 1
      $ret &= $bigInt[$i]
   Next

   Return $ret
EndFunc ; ==> _BigIntToString

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntToSci
; Description ...: Converts a BigInt array to scientific form.
; Syntax.........: _BigIntToSci ($bigInt)
; Parameters ....: $bigInt         - The existing array
; Return values .: Success         - A string sci form. eg: 8.23423e15
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is invalid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntToSci ($bigInt)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)

   Local $ret = _BigIntToString ($bigInt, 1), $iBound = StringLen ($ret)
   $ret = StringLeft ($ret, 16)
   Return StringLeft ($ret, 2) & "." & StringTrimLeft ($ret, 2) & "e" & $iBound - 2
EndFunc ; ==> _BigIntToSci

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntCheck
; Description ...: Checks if a BigInt value is valid.
; Syntax.........: _BigIntCheck ($bigInt)
; Parameters ....: $bigInt         - The existing array
; Return values .: Success         - 1
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is Not An array
;                                  |2 - Sign not present
;                                  |3 - Value is not number. @Extended holds the index
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntCheck ($bigInt)
   If IsArray ($bigInt) = 0 Then Return SetError (1, 0, 0)
   If ($bigInt[0] <> "+") And ($bigInt[0] <> "-") Then Return SetError (2, 0, 0)
   For $i = 1 to UBound ($bigInt) - 1
      If Not IsNumber ($bigInt[$i]) Then Return SetError (3, $i, 0)
   Next
   Return 1
EndFunc ; ==> _BigIntCheck

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntSetSign
; Description ...: Sets the sign of a big int (positive or negative)
; Syntax.........: _BigIntSetSign (ByRef $bigInt, $sSign)
; Parameters ....: $bigInt         - The BigInt array
;                  $sSign          - The sign to use ("+" or "-"). If -1 sign will be opposite to current.
; Return values .: Success         - 1
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is not valid. See BigIntCheck
;                                  |2 - $sSign is invalid.
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntSetSign (ByRef $bigInt, $sSign)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)

   If $sSign = -1 Then
      If ($bigInt[0] = "+") Or ($bigInt[0] = "") Then
         $bigInt[0] = "-"
      ElseIf $bigInt[0] = "-" Then
         $bigInt[0] = "+"
      Else ; Not Recognized BigInt!!
         Return SetError (2, 0, 0)
      EndIf
   ElseIf ($sSign = "+") Or ($sSign = "") Then
      $bigInt[0] = $sSign
   Else ; Not Recognized $sSign
      Return SetError (3, 0, 0)
   EndIf

   Return 1
EndFunc ; ==> _BigIntSetSign

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntGetSign
; Description ...: Gets the sign of a big int (positive or negative)
; Syntax.........: _BigIntGetSign ($bigInt)
; Parameters ....: $bigInt         - The BigInt array
; Return values .: Success         - The sign ("+", "-")
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is not valid. See BigIntCheck
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntGetSign ($bigInt)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)
   Return $bigInt[0]
EndFunc ; ==> _BigIntGetSign

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntAdd
; Description ...: Adds to bigints.
; Syntax.........: _BigIntAdd ($bigInt1, $bigint2)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
; Return values .: Success         - The answer in bigint form.
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntAdd ($bigInt1, $bigInt2)
   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
   If _BigIntCheck ($bigInt2) = 0 Then Return SetError (2, 0, 0)

   ; Set up values
   _BigIntSetEqualLengths ($bigInt1, $bigInt2)
   Local $bigIntSum[UBound ($bigInt1) + 1]
   _BigIntInitialize ($bigIntSum)

   ; Add values
   If $bigInt1[0] = $bigInt2[0] Then ; Same Signs
      $bigIntSum[0] = $bigInt1[0]
      For $i = 1 To (UBound ($bigInt1) - 1)
         $bigIntSum[$i] = $bigInt1[$i] + $bigInt2[$i] + $bigIntSum[$i]
         If $bigIntSum[$i] > 9 Then
            $bigIntSum[$i + 1] = 1
            $bigIntSum[$i] = $bigIntSum[$i] - 10
         EndIf
      Next
   Else
      For $i = 1 to UBound ($bigInt1) - 1
         $bigInt1[$i] += 0
         $bigInt2[$i] += 0
      Next
      _BigIntSetEqualLengths ($bigInt1, $bigInt2)
      $bigIntSum[0] = $bigInt1[0]
      For $i = 1 To (UBound ($bigInt1) - 1)
         $bigIntSum[$i] = $bigIntSum[$i] + $bigInt1[$i] - $bigInt2[$i]
         If $bigIntSum[$i] < 0 Then
            $bigIntSum[$i + 1] = -1
            $bigIntSum[$i] = $bigIntSum[$i] + 10
         EndIf
      Next
   EndIf

   Return _BigIntRemoveTrailingZeros ($bigIntSum)
EndFunc ; ==> _BigIntAdd

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntMinus
; Description ...: Takes bigint 1 away from bigint 2
; Syntax.........: _BigIntMinus ($bigInt1, $bigint2)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
; Return values .: Success         - The answer in bigint form.
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntMinus ($bigInt1, $bigInt2)
   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
   If _BigIntCheck ($bigInt2) = 0 Then Return SetError (2, 0, 0)
   If $bigInt1[0] = "-" Then
      If $bigInt2[0] = "-" Then
         $bigInt1[0] = "+"
         Return _BigIntAdd ($bigInt1, $bigInt2)
      Else
         $bigInt1[0] = "+"
         $ret = _BigIntAdd ($bigInt1, $bigInt2)
         $ret[0] = "-"
         Return $ret
      EndIf
   Else
      If $bigInt2[0] = "-" Then
         $bigInt2[0] = "+"
         Return _BigIntAdd ($bigInt1, $bigInt2)
      Else
         $bigInt2[0] = "-"
         Return _BigIntAdd ($bigInt1, $bigInt2)
      EndIf
   EndIf
EndFunc ; ==> _BigIntMinus

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntMultiply
; Description ...: Multiplies 2 bigints.
; Syntax.........: _BigIntMultiply ($bigInt1, $bigint2)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
; Return values .: Success         - The answer in bigint form.
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntMultiply ($bigInt1, $bigInt2)
   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
   If _BigIntCheck ($bigInt2) = 0 Then Return SetError (2, 0, 0)

   Local $temp = _BigIntMax ($bigInt1, $bigInt2), $sign = "-", $bigIntProduct[UBound ($temp) * 2]
   _BigIntInitialize ($bigIntProduct)

   If $bigInt1[0] = $bigInt2[0] Then $sign = "+"

   Local $total = _BigIntCreate(0)
   For $i = 1 To (UBound ($bigInt1) - 1)
      For $j = 1 To (UBound ($bigInt2) - 1)
         $bigIntProduct[$i + $j - 1] = Mod ($bigInt1[$i] * $bigInt2[$j], 10)
         $bigIntProduct[$i + $j] = Floor (($bigInt1[$i] * $bigInt2[$j]) /  10)
         $total = _BigIntAdd ($bigIntProduct, $total)
         $bigIntProduct = _BigIntCreate (0)
         Redim $bigIntProduct[UBound ($temp) * 2]
         _BigIntInitialize ($bigIntProduct)
      Next
   Next
   $total[0] = $sign

   Return _BigIntRemoveTrailingZeros ($total)
EndFunc ; ==> _BigIntMultiply

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntDivide
; Description ...: Divides 2 bigints.
; Syntax.........: _BigIntDivide ($bigInt1, $bigint2)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
; Return values .: Success         - The answer in bigint form.
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Mat
; Modified.......:
; Remarks .......: Not Working!
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

;Func _BigIntDivide ($bigInt1, $div)
;   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
;   If _BigIntCheck ($div) = 1 Then $div = _BigIntToString ($div) + 0
;
;   Local $temp = _BigIntMax ($bigInt1, $div), $ret[UBound ($bigInt1)]
;      $ret[0] = "+"
;
;   For $i = (UBound ($bigInt1) - 1) to 1 Step - 1
;      $ret[$i] = Int ($bigInt1[$i] / $div)
;      If (Int ($bigInt1[$i] / $div) = $bigInt1[$i] / $div) And ($i <= 1) Then ExitLoop
;      If $i = 0 Then $i += 1
;      $bigInt1[$i - 1] += (($bigInt1[$i] / $div) - Int ($bigInt1[$i] / $div)) * 10
;   Next
;
;   Return _BigIntRemoveTrailingZeros ($ret)
;EndFunc ; ==> _BigIntDivide

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntMax
; Description ...: Returns the Max of 2 big ints.
; Syntax.........: _BigIntMax ($bigInt1, $bigint2, $sMode)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
;                  $sMode          - The mode, default is "max", "min" is the min version!!!
; Return values .: Success         - The answer in bigint form. Error is 1 if they are the same, although BigInt1 will be returned
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt1 is not valid. See BigIntCheck
;                                  |3 - $sMode is not valid.
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntMax ($bigInt1, $bigInt2, $sMode="max")
   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
   If _BigIntCheck ($bigInt2) = 0 Then Return SetError (2, 0, 0)
   If ($sMode <> "max") And ($sMode <> "min") Then Return SetError (3, 0, 0)

   $bigInt1 = _BigIntRemoveTrailingZeros ($bigInt1)
   $bigInt2 = _BigIntRemoveTrailingZeros ($bigInt2)

   ; Checks array lengths. Longer array must be greater.
   If _BigIntEqual ($bigInt1, $bigInt2) = 1 Then
      Return SetError (1, 0, $bigInt1)
   ElseIf UBound ($bigInt1) > UBound ($bigInt2) Then
      Return $bigInt1
   ElseIf UBound ($bigInt1) < UBound ($bigInt2) Then
      Return $bigInt2
   EndIf

   ; Check individual numbers until they are different
   For $i = UBound ($bigInt1) - 1 To 1 Step - 1
      If $bigInt1[$i] > $bigInt2[$i] Then
         If $sMode="max" Then Return $bigInt1
            Return $bigInt2
      ElseIf $bigInt1[$i] < $bigInt2[$i] Then
         If $sMode="max" Then Return $bigInt2
            Return $bigInt1
      EndIf
   Next
EndFunc ; ==> _BigIntMax

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntMin
; Description ...: Returns the Min of 2 big ints. Uses the _BigIntMax functions with $sMode = "min"
; Syntax.........: _BigIntMin ($bigInt1, $bigint2)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
; Return values .: Success         - The answer in bigint form. Error is 1 if they are the same, although BigInt1 will be returned
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntMin ($bigInt1, $bigInt2)
   Return _BigIntMax ($bigInt1, $bigInt2, "min")
EndFunc ; ==> _BigIntMin

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntEqual
; Description ...: Checks to see if 2 bigInts are equal
; Syntax.........: _BigIntMin ($bigInt1, $bigint2)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second big int array
; Return values .: Success         - 1
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntEqual ($bigInt1, $bigInt2)
   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
   If _BigIntCheck ($bigInt2) = 0 Then Return SetError (2, 0, 0)

   $bigInt1 = _BigIntRemoveTrailingZeros ($bigInt1)
   $bigInt2 = _BigIntRemoveTrailingZeros ($bigInt2)

   ; Check lengths and then numbers
   If UBound ($bigInt1) <> UBound ($bigInt2) Then Return 0
   For $i = 0 To UBound ($bigInt1) - 1
      If $bigInt1[$i] <> $bigInt2[$i] Then Return SetExtended ($i, 0)
   Next

   Return 1
EndFunc ; ==> _BigIntEqual

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntRemoveTrailingZeros
; Description ...: Removes unnecessary zeros in a bigint added to equalize lengths.
; Syntax.........: _BigIntRemoveTrailingZeros ($bigInt)
; Parameters ....: $bigInt         - The big int array
; Return values .: Success         - The adjusted BigInt. Not this function does not use ByRef.
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt is not valid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntRemoveTrailingZeros ($bigInt)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)

   For $i = UBound ($bigInt) - 1 to 1 Step - 1
      If $bigInt[$i] <> 0 Then ExitLoop
   Next

   ReDim $bigint[$i + 1]
   Return $bigInt
EndFunc ; ==> _BigIntRemoveTrailingZeros

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntSetEqualLengths
; Description ...: Makes the 2 bigints eqwual in length by adding trailing zeros
; Syntax.........: _BigIntRemoveTrailingZeros ($bigInt)
; Parameters ....: $bigInt1        - The first big int array
;                  $bigInt2        - The second bigint array
; Return values .: Success         - 1
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $bigInt2 is not valid. See BigIntCheck
; Author ........: Wus
; Modified.......: Mat
; Remarks .......:
; Related .......: _BigIntRemoveTrailingZeros
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntSetEqualLengths (ByRef $bigInt1, ByRef $bigInt2)
   If _BigIntCheck ($bigInt1) = 0 Then Return SetError (1, 0, 0)
   If _BigIntCheck ($bigInt2) = 0 Then Return SetError (2, 0, 0)

   Local $arrayL1 = UBound ($bigInt1)
   Local $arrayL2 = UBound ($bigInt2)

   If $arrayL1 < $arrayL2 Then
      ReDim $bigInt1[$arrayL2]
   ElseIf $arrayL1 > $arrayL2 Then
      ReDim $bigInt2[$arrayL1]
   EndIf

   Return 1
EndFunc ; ==> _BigIntSetEqualLengths

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntSetLength
; Description ...: Sets the length of a BigInt by adding zeros
; Syntax.........: _BigIntSetLength (ByRef $bigInt, $len)
; Parameters ....: $bigInt         - The first big int array
;                  $len            - The length to set to
; Return values .: Success         - 1
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
;                                  |2 - $len is not valid. @Extended is set to:
;                                      |1 - Is not int
;                                      |2 - Is out of bounds
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......: _BigIntRemoveTrailingZeros
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntSetLength (ByRef $bigInt, $len)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)
   If Not IsInt ($len) Then Return SetError (2, 1, 0)
   If $len < 1 Then Return SetError (2, 2, 0)

   ReDim $bigInt[$len]
   Return 1
EndFunc ; ==> _BigIntSetLength

; #FUNCTION# =====================================================================================================================
; Name...........: _BigIntGetLength
; Description ...: Returns the length of a BigInt
; Syntax.........: _BigIntGetLength ($bigInt)
; Parameters ....: $bigInt         - The big int array
; Return values .: Success         - The Size of the BigInt
;                  Failure         - Returns 0,@Error =
;                                  |1 - $bigInt1 is not valid. See BigIntCheck
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _BigIntGetLength ($bigInt)
   If _BigIntCheck ($bigInt) = 0 Then Return SetError (1, 0, 0)
   Return UBound ($bigInt) - 1
EndFunc ; ==> _BigIntGetLength

; #FUNCTION# =====================================================================================================================
; Name...........: _FibonacciGetSequence
; Description ...: Returns the Fibonacci sequence up to an index or number.
; Syntax.........: _FibonacciGetSequence ($nUpToIndex [, $nUpToNum [, $nBigInt]] )
; Parameters ....: $nUpToIndex     - The index to go up to
;                  $nUpToNum       - (Optional) The number to go up to. Default = -1
;                  $nBigInt        - If 1 then the big int functions are used.
; Return values .: Success         - A string of the Fibonacci sequence
;                  Failure         - Returns 0,@Error =
;                                  |1 - $nUpToIndex is invalid
;                                  |2 - $nUpToNum is invalid
;                                  |3 - $nBigInt is invalid
;                                  |4 - Both upto's are -1
;                                  |5 - BigInt functions used but non existant
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _FibonacciGetSequence ($nUpToIndex, $nUpToNum = -1, $nBigInt = 0)
   If ($nUpToIndex < 1) AND ($nUpToIndex <> -1) Then Return SetError (1, 0, 0)
   If ($nUpToNum < 1) AND ($nUpToNum <> -1) Then Return SetError (2, 0, 0)

	If $nUpToIndex = -1 Then
      If $nUpToNum = -1 Then Return SetError (4, 0, 0)
      $nUpToIndex = _FibonacciGetIndex ($nUpToNum)
      $nUpToNum = -1
   EndIf
   If $nUpToNum <> -1 Then
      $temp = _FibonacciGetIndex ($nUpToNum)
      If $temp > $nUpToIndex Then $nUpToIndex = $temp
   EndIf

   Local $ret = 0
   If $nBigInt = 1 Then
      Call ("_BigIntCreate", 0)
      If (@ERROR = 0xDEAD) AND (@EXTENDED = 0xBEEF) Then Return SetError (5, 0, 0)
   	Local $first = _BigIntCreate (0), $second = _BigIntCreate (1), $temp
   	For $i = 1 to $nUpToIndex
         $temp = _BigIntAdd ($first, $second)
         $first = $second
         $second = $temp
         $ret &= "," & _bigIntToString ($first)
      Next
   ElseIf $nBigInt = 0 Then
      If $nUpToIndex > 1474 Then Return SetError (1, 0, 0)
      Local $first = 1, $second = 1
      $ret = "1"
   	For $i = 1 to $nUpToIndex
         $temp = $first + $second
         $first = $second
         $second = $temp
         $ret &= "," & $first
      Next
   Else
      Return SetError (3, 0, 0)
   EndIf
   Return $ret
Endfunc ; ==> _FibonacciGetSequence

; #FUNCTION# =====================================================================================================================
; Name...........: _FibonacciGet
; Description ...: Returns the Fibonacci number N
; Syntax.........: _FibonacciGet ($n)
; Parameters ....: $n              - The nth term
; Return values .: Success         - The Fibonacci Number
;                  Failure         - Returns 0,@Error =
;                                  |1 - $n is invalid
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _FibonacciGet ($n)
   If $n < 1 Then Return SetError (1, 0, 0)
   Return (1 / Sqrt (5)) * ((((1 + sqrt (5)) / 2) ^ $n) - (((1 - Sqrt (5)) / 2) ^ $n))
Endfunc ; ==> _FibonacciGet

; #FUNCTION# =====================================================================================================================
; Name...........: _FibonacciGetIndex
; Description ...: Returns the index for the fibonacci number
; Syntax.........: _FibonacciGet ($nNum)
; Parameters ....: $nNum           - The Fibonacci number
; Return values .: Success         - The Nth term
;                  Failure         - Returns 0,@Error =
;                                  |1 - $nNum is not a fibonacci number
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _FibonacciGetIndex ($nNum)
   If Not _FibonacciCheck ($nNum) Then Return SetError (1, 0, 0)
   Return Round ((Log ($nNum) + Log (5) / 2) / Log ((1 + Sqrt (5)) / 2))
EndFunc ; ==> _FibonacciGetIndex

; #FUNCTION# =====================================================================================================================
; Name...........: _FibonacciCheck
; Description ...: Checks if a fibonacci number is valid,
; Syntax.........: _FibonacciCheck ($nNum)
; Parameters ....: $nNum           - The Fibonacci number
; Return values .: Success         - 1
;                  Failure         - 0
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _FibonacciCheck ($nNum)
   If (IsInt (Sqrt ((5 * $nNum ^ 2) + 4))) Or IsInt ((Sqrt ((5 * $nNum ^ 2) - 4))) Then Return 1
   Return 0
EndFunc ; ==> _FibonacciCheck

; #FUNCTION# =====================================================================================================================
; Name...........: _MathRad
; Description ...: Returns the amount of degrees in Radians
; Syntax.........: _FibonacciGetSequence ($iDeg)
; Parameters ....: $iDeg           - The input in Degrees
; Return values .: Success         - the amount in radians
;                  Failure         - Returns 0,@Error =
;                                  |1 - $iDeg is invalid
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......: _MathDeg
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathRad ($iDeg)
   If Not IsNumber ($iDeg) Then Return SetError (1, 0, 0)
   Return $iDeg * (3.1415926535897932384/180)
EndFunc ; ==> _MathRad

; #FUNCTION# =====================================================================================================================
; Name...........: _MathDeg
; Description ...: Returns the amount of radians in degrees
; Syntax.........: _FibonacciGetSequence ($iRad)
; Parameters ....: $iRad           - The input in Radians
; Return values .: Success         - the amount in Degrees
;                  Failure         - Returns 0,@Error =
;                                  |1 - $iRad is invalid
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......: _MathRad
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathDeg ($iRad)
   If Not IsNumber ($iRad) Then Return SetError (1, 0, 0)
   Return $iRad / (3.1415926535897932384/180)
EndFunc ; ==> _MathDeg

; #FUNCTION# =====================================================================================================================
; Name...........: _MathSin
; Description ...: Trigonometric SINE function
; Syntax.........: _MathSin ($nIn [, $sAng] )
; Parameters ....: $nIn            - The input number
;                  $sAng           - The angle units. def = "deg".
; Return values .: the answer
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathSin ($nIn, $sAng = "deg")
   If $sAng = "deg" Then $nIn = _MathRad ($nIn)
   $nIn = sin ($nIn)
   If $sAng = "rad" Then $nIn = _MathRad ($nIn)
   Return $nIn
EndFunc ; ==> _MathSin

; #FUNCTION# =====================================================================================================================
; Name...........: _MathArcSin
; Description ...: Trigonometric ARC-SINE function
; Syntax.........: _MathArcSin ($nIn [, $sAng] )
; Parameters ....: $nIn            - The input number
;                  $sAng           - The angle units. def = "deg".
; Return values .: the answer
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathArcSin ($nIn, $sAng = "deg")
   If $sAng = "deg" Then $nIn = _MathRad ($nIn)
   $nIn = asin ($nIn)
   If $sAng = "rad" Then $nIn = _MathRad ($nIn)
   Return $nIn
EndFunc ; ==> _MathArcsin

; #FUNCTION# =====================================================================================================================
; Name...........: _MathCos
; Description ...: Trigonometric COSINE function
; Syntax.........: _MathCos ($nIn [, $sAng] )
; Parameters ....: $nIn            - The input number
;                  $sAng           - The angle units. def = "deg".
; Return values .: the answer
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathCos ($nIn, $sAng = "deg")
   If $sAng = "deg" Then $nIn = _MathRad ($nIn)
   $nIn = cos ($nIn)
   If $sAng = "rad" Then $nIn = _MathRad ($nIn)
   Return $nIn
EndFunc ; ==> _MathCos

; #FUNCTION# =====================================================================================================================
; Name...........: _MathArcCos
; Description ...: Trigonometric ARC-COSINE function
; Syntax.........: _MathArcCos ($nIn [, $sAng] )
; Parameters ....: $nIn            - The input number
;                  $sAng           - The angle units. def = "deg".
; Return values .: the answer
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathArcCos ($nIn, $sAng = "deg")
   If $sAng = "deg" Then $nIn = _MathRad ($nIn)
   $nIn = acos ($nIn)
   If $sAng = "rad" Then $nIn = _MathRad ($nIn)
   Return $nIn
EndFunc ; ==> _MathArcCos

; #FUNCTION# =====================================================================================================================
; Name...........: _MathTan
; Description ...: Trigonometric TANJENT function
; Syntax.........: _MathTan ($nIn [, $sAng] )
; Parameters ....: $nIn            - The input number
;                  $sAng           - The angle units. def = "deg".
; Return values .: the answer
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathTan ($nIn, $sAng = "deg")
   If $sAng = "deg" Then $nIn = _MathRad ($nIn)
   $nIn = tan ($nIn)
   If $sAng = "rad" Then $nIn = _MathRad ($nIn)
   Return $nIn
EndFunc ; ==> _MathTan

; #FUNCTION# =====================================================================================================================
; Name...........: _MathArcTan
; Description ...: Trigonometric ARC-TANGENT function
; Syntax.........: _MathArcTan ($nIn [, $sAng] )
; Parameters ....: $nIn            - The input number
;                  $sAng           - The angle units. def = "deg".
; Return values .: the answer
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathArcTan ($nIn, $sAng = "deg")
   If $sAng = "deg" Then $nIn = _MathRad ($nIn)
   $nIn = atan ($nIn)
   If $sAng = "rad" Then $nIn = _MathRad ($nIn)
   Return $nIn
EndFunc ; ==> _MathArcTan

; #FUNCTION# =====================================================================================================================
; Name...........: _MathRoot
; Description ...: Finds the nth root of $iNumber
; Syntax.........: _MathRoot ($iNumber [, $nExp] )
; Parameters ....: $fNum           - The input number
;                  $nExp           - The root. Def = 3
; Return values .: Success         - the answer
;                  Failure         - Returns 0,@Error =
;                                  |1 - $nExp is invalid
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathRoot($fNum, $nExp = 3)
   Local $bNeg = False, $fRet = 0
   If $nExp < 0 Then Return SetError (1, 0, $fNum)

   If $fNum < 0 Then ; is negative
      If Mod($nExp, 2) Then ; nExp is odd, so negative IS possible.
         $bNeg = True
         $fNum *= -1
      Else
         Return SetError(1, 0, $fNum & "i") ; Imaginary number.
      EndIf
   EndIf

   $fRet = $fNum ^ (1 / $nExp)
   If $bNeg Then $fRet *= -1
   Return $fRet
EndFunc ; ==> _MathRoot

; #FUNCTION# ;====================================================================================================================
;
; Name...........: _MathRound
; Description ...: A more advanced round function
; Syntax.........: _MathRound ($nNum [, $nPlaces [, $nDirection [, $nType [, $nTieMethod [, $nPad]]]]] )
; Parameters ....: $nNum       - The number to round
;                  $nPlaces    - The number of places to round to
;                  $nDirection - the direction to round
;                  $nType      - the type of rounding
;                  $nTieMethod - the method of rounding a half.
; Return values .: Success - Returns the rounded value
;                  Failure - Returns 0 and Sets @Error and @Extended.
;                  |0 - No error.
;                  |1 - Variable is not of correct type
;                          *1 $nNum
;                          *2 $nPlaces
;                          *3 $nDirection
;                          *4 $nType
;                          *5 $nTieMethod
;                          *6 $nPad
;                  |2 - Variable out of range
;                          *1 $nNum
;                          *2 $nPlaces
;                          *3 $nDirection
;                          *4 $nType
;                          *5 $nTieMethod
;                          *6 $nPad
; Author ........: Mat
; Modified.......:
; Remarks .......: See the constants declared at the top of the UDF to see what values to use.
; Related .......:
; Link ..........;
; Example .......; Yes
;
; ;==============================================================================================================================

Func _MathRound ($nNum, $nPlaces = Default, $nDirection = 1, $nType = 1, $nTieMethod = 5, $nPad = 0)

   ; Check Variable Types
   If Not IsNumber ($nNum) Then Return SetError (1, 1, 0) ; Variable is not numeric type: nNum
   If (Not IsNumber ($nPlaces)) AND ($nPlaces <> Default) Then _
      Return SetError (1, 2, 0) ; Variable is not correct type: nPlaces
   If Not IsNumber ($nDirection) Then Return SetError (1, 3, 0) ; Variable is not numeric type: nDirection
   If Not IsNumber ($nType) Then Return SetError (1, 4, 0) ; Variable is not numeric type: nType
   If Not IsNumber ($nTieMethod) Then Return SetError (1, 5, 0) ; Variable is not numeric type: nTieMethod
   If Not IsNumber ($nPad) Then Return SetError (1, 6, 0) ; Variable is not numeric type: nTieMethod

   ; correct defaults NB: $nPlaces is corrected on its own depending on the value of $nType
   If $nDirection = Default Then $nDirection = 1
   If $nType = Default Then $nType = 1
   If $nTieMethod = Default Then $nTieMethod = 5
   If $nPad = Default Then $nPad = 0

   ; Adjust for types
   If $nType = 1 Then ; Decimal Places Used
      If $nPlaces = Default Then $nPlaces = 2
   ElseIf $nType = 2 Then ; significant figures used
      If $nPlaces = Default Then $nPlaces = 3
      If $nPlaces < 0 Then Return SetError (2, 2, 0)
      $nPlaces += StringLen (StringRegExpReplace (StringReplace (StringReplace ($nNum, ".", ""), "-", ""), "\A(0*)(.*)", "\1"))
      $nPlaces -= StringLen (StringRegExpReplace (StringReplace ($nNum, "-", ""), "\..*", ""))
   ElseIf $nType = 3 Then
      If $nPlaces = Default Then $nPlaces = 3
      If $nPlaces < 0 Then Return SetError (2, 2, 0)
      $nPlaces -= StringLen (StringRegExpReplace (StringReplace ($nNum, "-", ""), "\..*", ""))
   Else
      Return SetError (2, 4, 0)
   EndIf

   ; do the math!
   If $nDirection = 1 Then ; nearest
      If $nTieMethod = 1 Then
         $nNum = ceiling ($nNum * (10^$nPlaces)) / 10^$nPlaces
      ElseIf $nTieMethod = 2 Then
         $nNum = floor ($nNum * (10^$nPlaces)) / 10^$nPlaces
      ElseIf $nTieMethod = 3 Then ; To Zero
         If $nNum > 0 Then
            $nNum = ceiling ($nNum * (10^$nPlaces)) / 10^$nPlaces
         ElseIf $nNum < 0 Then
            $nNum = floor ($nNum * (10^$nPlaces)) / 10^$nPlaces
         Else
            $nNum = 0
         EndIf
      ElseIf $nTieMethod = 4 Then ; From Zero
         $nNum = Round ($nNum, $nPlaces)
      ElseIf $nTieMethod = 5 Then ; ToEven
         If $nNum < 0 Then
            $nNum *= 10^$nPlaces
            $nNum = Round ($nNum, 1)
            If Mod ($nNum, 1) = -0.5 Then
               If Mod (Int ($nNum), 2) = -1 Then ; odd
                  $nNum -= 0.5
               Else
                  $nNum += 0.5
               EndIf
               $nNum /= (10^$nPlaces)
            Else
               $nNum = Round ($nNum / (10^$nPlaces), $nPlaces)
            EndIf
         ElseIf $nNum > 0 Then
            $nNum *= 10^$nPlaces
            $nNum = Round ($nNum, 1)
            If Mod ($nNum, 1) = 0.5 Then
               If Mod (Int ($nNum), 2) = 1 Then ; odd
                  $nNum += 0.5
               Else
                  $nNum -= 0.5
               EndIf
               $nNum /= (10^$nPlaces)
            Else
               $nNum = Round ($nNum / (10^$nPlaces), $nPlaces)
            EndIf
         Else
            $nNum = 0
         EndIf
      ElseIf $nTieMethod = 6 Then
         If $nNum < 0 Then
            $nNum *= 10^$nPlaces
            $nNum = Round ($nNum, 1)
            If Mod ($nNum, 1) = -0.5 Then
               If Mod (Int ($nNum), 2) = -1 Then ; odd
                  $nNum += 0.5
               Else
                  $nNum -= 0.5
               EndIf
               $nNum /= (10^$nPlaces)
            Else
               $nNum = Round ($nNum / (10^$nPlaces), $nPlaces)
            EndIf
         ElseIf $nNum > 0 Then
            $nNum *= 10^$nPlaces
            $nNum = Round ($nNum, 1)
            If Mod ($nNum, 1) = 0.5 Then
               If Mod (Int ($nNum), 2) = 1 Then ; odd
                  $nNum -= 0.5
               Else
                  $nNum += 0.5
               EndIf
               $nNum /= (10^$nPlaces)
            Else
               $nNum = Round ($nNum / (10^$nPlaces), $nPlaces)
            EndIf
         Else
            $nNum = 0
         EndIf
      ElseIf $nTieMethod = 7 Then
         $nNum *= 10^$nPlaces
         $nNum = Round ($nNum, 1)
         If (Mod ($nNum, 1) = 0.5) Or (Mod ($nNum, 1) = -0.5) Then
            If Random (1, 2, 1) > 1 Then
               $nNum = Floor ($nNum)
            Else
               $nNum = Ceiling ($nNum)
            EndIf
            $nNum /= (10^$nPlaces)
         Else
            $nNum = Round ($nNum / (10^$nPlaces), $nPlaces)
         EndIf
      ElseIf $nTieMethod = 8 Then
         $nNum *= 10^$nPlaces
         $nNum = Round ($nNum, 1)
         MsgBox (0, "", $nNum)
         If (Mod ($nNum, 1) = 0.5) Or (Mod ($nNum, 1) = -0.5) Then
            $RND_TIE_ALT_CUR += 1
            If Mod ($RND_TIE_ALT_CUR, 2) = 1 Then ; down
               If $nNum > 0 Then
                  $nNum = ceiling ($nNum * (10^$nPlaces)) / 10^$nPlaces
               ElseIf $nNum < 0 Then
                  $nNum = floor ($nNum * (10^$nPlaces)) / 10^$nPlaces
               Else
                  $nNum = 0
               EndIf
            Else
               If $nNum < 0 Then
                  $nNum = ceiling ($nNum * (10^$nPlaces)) / 10^$nPlaces
               ElseIf $nNum > 0 Then
                  $nNum = floor ($nNum * (10^$nPlaces)) / 10^$nPlaces
               Else
                  $nNum = 0
               EndIf
            EndIf
            $nNum /= (10^$nPlaces)
         Else
            $nNum = Round ($nNum / (10^$nPlaces), $nPlaces)
         EndIf
      Else
         Return SetError (2, 5, 0)
      EndIf
   ElseIf $nDirection = 2 Then ; up
      If $nNum > 0 Then
         $nNum = Int ($nNum * (10^$nPlaces) + 1) / (10^$nPlaces)
      ElseIf $nNum < 0 Then
         $nNum = Int ($nNum * (10^$nPlaces)) + 1
         If $nNum < 0 Then
            $nNum -= 1
         ElseIf $nNum > 0 Then
            $nNum += 1
         Else
            Return 0
         EndIf
         $nNum = $nNum / (10^$nPlaces)
      Else
         Return 0
      EndIf
   ElseIf $nDirection = 3 Then ; down
      If $nNum > 0 Then
         $nNum = Int ($nNum * (10^$nPlaces)) / (10^$nPlaces)
      ElseIf $nNum < 0 Then
         $nNum = Int ($nNum * (10^$nPlaces))
         If $nNum < 0 Then
            $nNum -= 1
         ElseIf $nNum > 0 Then
            $nNum += 1
         Else
            Return 0
         EndIf
         $nNum = $nNum / (10^$nPlaces)
      Else
         Return 0
      EndIf
   ElseIf $nDirection = 4 Then ; trunc
      $nNum = Int ($nNum * (10^$nPlaces)) / (10^$nPlaces)
   ElseIf $nDirection = 5 Then ; ! trunc
      $nNum = Int ($nNum * (10^$nPlaces))
      If $nNum < 0 Then
         $nNum -= 1
      ElseIf $nNum > 0 Then
         $nNum += 1
      Else
         Return 0
      EndIf
      $nNum = $nNum / (10^$nPlaces)
   ElseIf $nDirection = 6 Then ; Dither
      If $nNum < 0 Then
         $nNum *= -1
         $nNum *= 10^$nPlaces
         $fract = StringRegExpReplace (Mod ($nNum, 1), ".*\.", "")
         If Random (0, 10^StringLen ($fract), 1) > $fract Then ; up
            $nNum = Ceiling ($nNum)
         Else ; down
            $nNum = Floor ($nNum)
         EndIf
         $nNum /= 10^$nPlaces
         $nNum *= -1
      ElseIf $nNum > 0
         $nNum *= 10^$nPlaces
         $fract = StringRegExpReplace (Mod ($nNum, 1), ".*\.", "")
         If Random (0, 10^StringLen ($fract), 1) > $fract Then ; up
            $nNum = Ceiling ($nNum)
         Else ; down
            $nNum = Floor ($nNum)
         EndIf
         $nNum /= 10^$nPlaces
      Else
         Return 0
      EndIf
   Else
      Return SetError (2, 3, 0)
   EndIf
   If $nPad = 1 Then
      Return __Pad ($nNum, $nPlaces)
   ElseIf $nPad = 0 Then
      Return $nNum
   Else
      Return SetError (2, 6, 0)
   EndIf
EndFunc ; ==> _MathRound

; #INTERNAL_USE_ONLY# ;===========================================================================================================
;
; Name...........: __Pad
; Description ...: For padding results
; Syntax.........: __Pad ($nNum, $nPlaces)
; Parameters ....: $nNum     - The number
;                  $nPlaces  - The amount of places to pad to
; Return values .: Padded result
; Author ........: Mat
; Modified.......:
; Remarks .......: Internal use only.
; Related .......:
; Link ..........;
; Example .......; no
;
; ================================================================================================================================

Func __Pad ($nNum, $nPlaces)
   If Not IsNumber ($nNum) Then Return SetError (1, 1, 0) ; Variable is not of correct type
   If Not IsNumber ($nPlaces) Then Return SetError (1, 2, 0) ; Variable is not of correct type

   If Not StringInStr ($nNum, ".") Then
      If $nPlaces > 0 Then $nNum &= "."
   EndIf

   $nLen = StringLen (StringRegExpReplace ($nNum, ".*\.", ""))

   $sZeros = ""
   For $i = 1 to $nPlaces - $nLen
      $sZeros &= 0
   Next
   Return $nNum & $sZeros
EndFunc ; ==> __Pad

; #FUNCTION# =====================================================================================================================
; Name...........: _MathQuadratic
; Description ...: Returns an array with information about the quadratic equation
; Syntax.........: _MathQuadratic ($sSum)
; Parameters ....: $sSum           - The input string quadratic
; Return values .: Success         - an array with info about the sum:
;                                  |0 - The formula
;                                  |1 - Result 1
;                                  |2 - Result 2
;                                  |3 - The min point of a curve.
;                  Failure         - Returns 0,@Error =
;                                  |1 - $sSum is invalid
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _MathQuadratic ($sSum)
   $sSum = StringStripWS ($sSum, 8)
   $sTest = "([+;-]?[0-9;\.]*)x\^2([+;-][0-9;\.]*)x([+;-][0-9;\.]*)?=0"
   If StringRegExp ($sSum, "([+;-]?[0-9;\.]*),([+;-]?[0-9;\.]*)(,[+;-]?[0-9;\.]*)?", 0) Then _
      $sTest = "([+;-]?[0-9;\.]*),([+;-]?[0-9;\.]*)(,[+;-]?[0-9;\.]*)?"
   If StringRight ($sSum, 2) <> "=0" Then
      If StringInStr ($sSum, "=") Then Return SetError (1, 0, 0) ; Formula <> 0
      $sSum &= "=0"
   EndIf
   $a = StringRegExp ($sSum, $sTest, 1)
   If UBound ($a) = 2 Then ; no c?
      ReDim $a[3]
      $a[2]= 0
   EndIf
   If UBound ($a) <> 3 Then Return SetError (1, 0, 0)
   $a[2] = StringReplace ($a[2], ",", "") + 0
   Local $ret[4] = [0,0,0,0]
   $ret[0] = "X={" & 0 - $a[1] & Chr (177) & "v(" & $a[1] & (4 * $a[0] * $a[2]) & ")}" & "/" & (2 * $a[0])
   $ret[1] = (0 - $a[1] + sqrt (($a[1] ^ 2) - 4 * $a[0] * $a[2])) / (2 * $a[0])
   $ret[2] = (0 - $a[1] - sqrt (($a[1] ^ 2) - 4 * $a[0] * $a[2])) / (2 * $a[0])
   $ret[3] = "(" & ((0 - $a[1]) / (2 * $a[0])) & "," & (($a[0] * (((0 - $a[1]) / (2 * $a[0]))^2)) + ($a[1] * ((0 - $a[1]) / (2 * $a[0]))) + $a[2]) & ")"
   Return $ret
EndFunc ; ==> _MathQuadratic

; #FUNCTION# =====================================================================================================================
; Name...........: _PascalGetLine
; Description ...: Returns the line of pascals triangle
; Syntax.........: _PascalGetLine ($nLine [, $sSep] )
; Parameters ....: $nLine          - The line number
;                  $sSep           - The seperator character. default is space (" ")
; Return values .: Success         - a string with the result seperated by $sSep
;                  Failure         - Returns blank string,@Error =
;                                  |1 - $nLine is invalid
; Author ........: Mat
; Modified.......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ================================================================================================================================

Func _PascalGetLine ($nLine, $sSep = " ")
   If ($nLine < 1) Or (Not IsInt ($nLine)) Then Return SetError (1, 0, "")
   Local $sRet = " "

   For $i = 1 to $n
      $sRet &= __Diag ($n - $i + 1, $i) & $sSep
   Next

   $sRet = StringtrimRight ($sRet, 1)

   Return $sRet
EndFunc ; ==> _PascalGetLine

; #INTERNAL_USE_ONLY# ;===========================================================================================================
;
; Name...........: __Diag
; Description ...: Retrieves a digonal for pascals triangle.
; Syntax.........: __Diag ($n, $d)
; Parameters ....: $n        - The valeue of n
;                  $d        - The diagonal.
; Return values .: the value of that diagonal.
; Author ........: Mat
; Modified.......:
; Remarks .......: Internal use only.
; Related .......:
; Link ..........;
; Example .......; no
;
; ================================================================================================================================

Func __Diag ($n, $d)
   If $d = 1 then return 1

   Local $ret = $n

   For $i = 1 to $d - 2
      $ret *= $n + $i
   Next
   $ret /= fact ($d - 1)

   Return $ret
EndFunc ; ==> __Diag












