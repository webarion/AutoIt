
#include <dev.au3>


Global $igDEBUG_HelperHTTP = 1

Global $igInit_HelperHTTP = 0
Global $ogObject_HelperHTTP, $igTimeout_HelperHTTP = 5000
Global $hgTimer_HelperHTTP = 0, $sgResponse_Function_HelperHTTP = '', $sgRespData_HelperHTTP = ''

Global $sgUserAgent_HelperHTTP = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4250.0 Iron Safari/537.36' ; Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)
Global $sgContentType_HelperHTTP = 'application/x-www-form-urlencoded'
Global $ogHeaders_HelperHTTP = ObjCreate('Scripting.Dictionary')

$sgContentType_HelperHTTP.Item('User-Agent') = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4250.0 Iron Safari/537.36'
$sgContentType_HelperHTTP.Item('Content-Type') = 'application/x-www-form-urlencoded'


; Пример. Example =========
$sURL = 'https://api.github.com/users/defunkt' ; http://webarion.ru/_tests/

_Response_Function_HelperHTTP('MyFunc')

_Request_HelperHTTP($sURL, '')

;~ _Request_HelperHTTP($sURL, '', 'MyFunc')

;~ _CallbackRegister_HelperHTTP()

Sleep($igTimeout_HelperHTTP)

Func MyFunc($sData)
	_P($sData)
EndFunc   ;==>MyFunc
; =========================



Func _Init_HelperHTTP($sMethod = '')
	If $igInit_HelperHTTP Then Return 1
	Local $aMethod_HelperHTTP = ['Msxml2.XMLHTTP.6.0', 'Msxml2.XMLHTTP.5.0', 'Msxml2.XMLHTTP.4.0', 'Microsoft.XMLHTTP', 'winhttp.winhttprequest.5.1']
	If $sMethod Then
		$aMethod_HelperHTTP[0] = $sMethod
		ReDim $aMethod_HelperHTTP[1]
	EndIf
	For $i = 0 To UBound($aMethod_HelperHTTP) - 1
		$ogObject_HelperHTTP = ObjCreate($aMethod_HelperHTTP[$i])
		If Not @error Then ExitLoop
	Next
	If $i = UBound($aMethod_HelperHTTP) Then Return SetError(1, __Debug_HelperHTTP('Not find HTTP object', @ScriptLineNumber), 0)

	__Debug_HelperHTTP('+Ok Init HTTP object (' & $aMethod_HelperHTTP[$i] & ')', @ScriptLineNumber)
	Global $ogError_HelperHTTP = ObjEvent('AutoIt.Error', '__Debug_HelperHTTP')
	Return 1
EndFunc   ;==>_Init_HelperHTTP

Func _Response_Function_HelperHTTP($sRespFunc)
	If $sRespFunc Then $sgResponse_Function_HelperHTTP = $sRespFunc
EndFunc   ;==>_Response_Function_HelperHTTP

Func _UserAgent_HelperHTTP($sUserAgent)
	$sgUserAgent_HelperHTTP = $sUserAgent
EndFunc   ;==>_UserAgent_HelperHTTP

Func _ContentType_HelperHTTP($sContentType)
	$sgContentType_HelperHTTP = $sContentType
EndFunc   ;==>_UserAgent_HelperHTTP

Func _AddHeader_HelperHTTP($sHeaderName, $sHeaderParams)

EndFunc

Func _Request_HelperHTTP($sURL, $sParams = '', $sMethod = 'GET', $sCallbackFunction = '', $sUserAgent = '', $sContentType = '')
	If Not IsObj($ogObject_HelperHTTP) Then _Init_HelperHTTP()
	If @error Then Return SetError(1, __Debug_HelperHTTP('No request object', @ScriptLineNumber-1), 0)

	$ogObject_HelperHTTP.Open($sMethod, $sURL, True)
	If @error Then Return SetError(2, __Debug_HelperHTTP('Failed to execute HTTP.Open', @ScriptLineNumber-1), 0)

	$sUserAgent = $sUserAgent ? $sUserAgent : $sgUserAgent_HelperHTTP
	$sContentType = $sContentType ? $sContentType : $sgContentType_HelperHTTP

	$ogObject_HelperHTTP.SetRequestHeader('User-Agent', $sUserAgent)
	$ogObject_HelperHTTP.SetRequestHeader('Content-Type', $sContentType)

;~ 	$ogObject_HelperHTTP.setRequestHeader("Authorization", "Bearer " & '0b1ec66ab3096ae07b8d086a57f39192c876961a')
;~ 	$ogObject_HelperHTTP.setRequestHeader("Accept", "application/vnd.github." & 3 & "+json")

	$hgTimer_HelperHTTP = TimerInit()

	$ogObject_HelperHTTP.Send($sParams)
	If @error Then Return SetError(3, __Debug_HelperHTTP('Failed to execute HTTP.Send', @ScriptLineNumber-1), 0)

	If $sCallbackFunction Then $sgResponse_Function_HelperHTTP = $sCallbackFunction

;~     ConsoleWrite('+> Status: ' & $ogObject_HelperHTTP.Status & @CRLF)
;~     ConsoleWrite('+> StatusText: ' & $ogObject_HelperHTTP.StatusText & @CRLF)
;~     ConsoleWrite('+> ResponseText: ' & @CRLF & $ogObject_HelperHTTP.ResponseText & @CRLF)
;~     ConsoleWrite(@CRLF)

	AdlibRegister('_Async_HelperHTTP', 300)

	Return 1
EndFunc   ;==>_Request_HelperHTTP

;*******

Func _Async_HelperHTTP()
	$sgRespData_HelperHTTP = ''
	If $ogObject_HelperHTTP.readyState = 4 Then
		Local $sgRespData_HelperHTTP = $ogObject_HelperHTTP.ResponseText

		If Not @error Then
			AdlibUnRegister('_Async_HelperHTTP')
			_Callback_HelperHTTP($sgRespData_HelperHTTP)
			Return $sgRespData_HelperHTTP
		EndIf
	EndIf

	If $hgTimer_HelperHTTP And TimerDiff($hgTimer_HelperHTTP) > $igTimeout_HelperHTTP Then
		AdlibUnRegister('_Async_HelperHTTP')
		$hgTimer_HelperHTTP = 0
		_Callback_HelperHTTP('', 1)
	EndIf

EndFunc   ;==>_Async_HelperHTTP

Func _isTimeoutHTTP()
	If $hgTimer_HelperHTTP And TimerDiff($hgTimer_HelperHTTP) > $igTimeout_HelperHTTP Then Return 1
	Return 0
EndFunc   ;==>_isTimeoutHTTP

Func _Callback_HelperHTTP($sData, $iTimeoutExceeded = 0)
	If Not $sgResponse_Function_HelperHTTP Then
		__Debug_HelperHTTP('Callback function not registered', @ScriptLineNumber)
		Return SetError(1, 0, 0)
	EndIf
	If $iTimeoutExceeded Then __Debug_HelperHTTP('Timeout exceeded. Increase the waiting time for a response in $ igTimeout_HelperHTTP', @ScriptLineNumber)
	Call($sgResponse_Function_HelperHTTP, $sData)
	If @error = 0xDEAD And @extended = 0xBEEF Then
		Call($sgResponse_Function_HelperHTTP, $sData, $iTimeoutExceeded)
		If @error = 0xDEAD And @extended = 0xBEEF Then __Debug_HelperHTTP('Failed to Call function ' & $sgResponse_Function_HelperHTTP & '. The wrong number of parameters may be specified', @ScriptLineNumber)
	EndIf
EndFunc   ;==>_Callback_HelperHTTP





Func URLEncode($urlText)
	Local $url = "", $acode
	For $i = 1 To StringLen($urlText)
		$acode = Asc(StringMid($urlText, $i, 1))
		Select
			Case ($acode >= 48 And $acode <= 57) Or _
					($acode >= 65 And $acode <= 90) Or _
					($acode >= 97 And $acode <= 122)
				$url = $url & StringMid($urlText, $i, 1)
			Case $acode = 32
				$url = $url & "+"
			Case Else
				$url = $url & "%" & Hex($acode, 2)
		EndSelect
	Next
	Return $url
EndFunc   ;==>URLEncode

Func URLDecode($urlText)
	$urlText = StringReplace($urlText, "+", " ")
	Local $matches = StringRegExp($urlText, "\%([abcdefABCDEF0-9]{2})", 3)
	If Not @error Then
		For $match In $matches
			$urlText = StringReplace($urlText, "%" & $match, BinaryToString('0x' & $match))
		Next
	EndIf
	Return $urlText
EndFunc   ;==>URLDecode

Func HTTP_Ping($sHost, $iTm = 1000, $iCicle = 3)
	Local $var, $iTime = 0
	While 1
		$var = Ping(StringRegExpReplace($sHost, ".+?//(.+?)/.+", "$1"), $iTm)
		If $var Then Return $var
		Sleep(100)
		$iTime += 1
		If $iTime >= $iCicle Then
			ConsoleWrite('Ping error: ' & $sHost)
			Return SetError(1, 0, 0)
		EndIf
	WEnd
EndFunc   ;==>HTTP_Ping

Func _ParsURL($sURL, $iUrlCode = 1)
	Local $aComplete[4] = ['http://', '', '', '']
	Local $aSplitURL = StringSplit($sURL, '?', 2)
	If UBound($aSplitURL) > 0 Then
		Local $aParsURL = StringRegExp($aSplitURL[0], '(^https?://|^)(.*?)(/.*|$)$', 1)
		If IsArray($aParsURL) Then
			If $aParsURL[0] Then $aComplete[0] = $aParsURL[0]
			If $aParsURL[1] Then $aComplete[1] = $aParsURL[1]
			If $aParsURL[2] Then $aComplete[2] = $aParsURL[2]
		EndIf
	EndIf
	If UBound($aSplitURL) = 2 Then
		$aComplete[3] = $aSplitURL[1]
		If $iUrlCode Then URLEncode($aComplete[3])
	EndIf
	Return $aComplete
EndFunc   ;==>_ParsURL

;**********************************************************************
; Генерация строки
;**********************************************************************
Func _GenSessinoKey($iLength = 64)
	Local $sResult
	Local $sSequence = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
	Local $aSplit = StringSplit($sSequence, "", 2)
	For $i = 1 To $iLength
		$sResult &= $aSplit[Random(0, UBound($aSplit) - 1, 1)]
	Next
	Return $sResult
EndFunc   ;==>_GenSessinoKey


Func __Debug_HelperHTTP($ogError_HelperHTTP, $iScriptLine = '')
	If IsString($ogError_HelperHTTP) Then
		Local $sSign = StringLeft($ogError_HelperHTTP, 1)
		Local $iSign = StringInStr('>!-+', $sSign) ? $sSign : ''
		$ogError_HelperHTTP = $iSign ? StringRight($ogError_HelperHTTP, StringLen($ogError_HelperHTTP) - 1) : $ogError_HelperHTTP
		Local $sMsg = $iSign & @ScriptName & ' (' & $iScriptLine & ') : ==> ' & $ogError_HelperHTTP & '!'

		If $igDEBUG_HelperHTTP Then ConsoleWrite($sMsg & @CRLF)
		Return SetError(1, 0, 0)
	ElseIf Not IsObj($ogError_HelperHTTP) Then
		Return SetError(2, 0, 0)
	EndIf
	Local $iErrNumber = Hex($ogError_HelperHTTP.number, 8)
	If $igDEBUG_HelperHTTP Then
		Local $sWindescription = $ogError_HelperHTTP.windescription
		Local $sDescription = $ogError_HelperHTTP.description
		Local $sSource = $ogError_HelperHTTP.source
		Local $sHelpfile = $ogError_HelperHTTP.helpfile
		Local $sHelpcontext = $ogError_HelperHTTP.helpcontext
		Local $sLastdllerror = $ogError_HelperHTTP.lastdllerror
		Local $sRetcode = "0x" & Hex($ogError_HelperHTTP.retcode)
		ConsoleWrite(@ScriptName & " (" & $ogError_HelperHTTP.scriptline & ") : ==> COM Error intercepted!" & @CRLF)
		ConsoleWrite("Number is: " & @TAB & @TAB & "0x" & $iErrNumber & @CRLF)
		If $sWindescription Then ConsoleWrite("Windescription:" & @TAB & $sWindescription & @CRLF)
		If $sDescription Then ConsoleWrite("Description is: " & @TAB & $sDescription & @CRLF)
		If $sSource Then ConsoleWrite("Source is: " & @TAB & @TAB & $sSource & @CRLF)
		If $sHelpfile Then ConsoleWrite("Helpfile is: " & @TAB & $sHelpfile & @CRLF)
		If $sHelpcontext Then ConsoleWrite("Helpcontext is: " & @TAB & $sHelpcontext & @CRLF)
		If $sLastdllerror Then ConsoleWrite("Lastdllerror is: " & @TAB & $sLastdllerror & @CRLF)
		If $sRetcode Then ConsoleWrite("Retcode is: " & @TAB & $sRetcode & @CRLF & @CRLF)
	EndIf
	Return SetError(3, $iErrNumber, 0)
EndFunc   ;==>__Debug_HelperHTTP

