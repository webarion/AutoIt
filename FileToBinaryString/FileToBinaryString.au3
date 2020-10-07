; Authors: @AZJIO and Webarion
#NoTrayIcon

$Gui = GUICreate(__Tr_FTBS('Конвертер файла в бинарную строку', 'File to binary string converter'), 330, 94, -1, -1, -1, 0x00000010)

$Input1 = GUICtrlCreateLabel('', 0, 0, 300, 94)
GUICtrlSetState(-1, 136)
GUICtrlCreateLabel(__Tr_FTBS('Перетащите сюда файл для конвертации в бинарную строку', 'Throw a file here to convert to a binary string'), 10, 2, 320, 17)
$StatusBar = GUICtrlCreateLabel(@CRLF & @CRLF, 10, 23, 280, 57)

GUISetState()

While 1
	$msg = GUIGetMsg()
	Select
		Case $msg = -13
			$filename = StringRegExp(@GUI_DragFile, '(^.*)\\(.*)\.(.*)$', 3)
			GUICtrlSetData($StatusBar, __Tr_FTBS('Файл', 'File') & ' ' & $filename[1] & '.' & $filename[2] & ' ' & __Tr_FTBS('принят', 'is accepted') & @CRLF & __Tr_FTBS('идёт чтение', 'Read') & '...')
			$ScrBin = '$sData  = ''0x''' & @CRLF
			$file = FileOpen(@GUI_DragFile, 16)
			While 1
				$Bin = FileRead($file, 2040)
				If @error = -1 Then ExitLoop
				$ScrBin &= '$sData  &= ''' & StringTrimLeft($Bin, 2) & '''' & @CRLF
				Sleep(1)
			WEnd
			FileClose($file)
			GUICtrlSetData($StatusBar, __Tr_FTBS('Файл', 'File') & ' ' & $filename[1] & '.' & $filename[2] & ' ' & __Tr_FTBS('принят', 'is accepted') & @CRLF & __Tr_FTBS('идёт запись', 'Write') & '...')

			$Output = $filename[0] & '\Bin'
			$i = 1
			While FileExists($Output & $i & '_' & $filename[1] & '.au3')
				$i += 1
			WEnd
			$Output = $Output & $i & '_' & $filename[1] & '.au3'

			$file = FileOpen($Output, 2)
			FileWrite($file, $ScrBin & @CRLF & _
					'$sData=Binary($sData)' & @CRLF & _
					'$file = FileOpen(@ScriptDir&''\Copy_' & $filename[1] & '.' & $filename[2] & ''',18)' & @CRLF & _
					'FileWrite($file, $sData)' & @CRLF & _
					'FileClose($file)')
			FileClose($file)
			GUICtrlSetData($StatusBar, __Tr_FTBS('Файл', 'File') & ' ' & $filename[1] & '.' & $filename[2] & ' ' & __Tr_FTBS('принят', 'is accepted') & @CRLF & __Tr_FTBS('Скрипт-файл с бинарными данными', 'Script file with binary data') & ' ' & __Tr_FTBS('создан', 'is created') & ': ' & 'Bin' & $i & '_' & $filename[1] & '.au3')
		Case $msg = -3
			Exit
	EndSelect
WEnd

Func __Tr_FTBS($sRus_VP, $sEng_VP)
	If Not IsDeclared('iLangOS_VP') Then Global $iLangOS_VP = @OSLang
	Return $iLangOS_VP = 419 ? $sRus_VP : $sEng_VP
EndFunc   ;==>__Tr_FTBS
