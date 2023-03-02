; Malu Renamer
; 	by Arion Krause
; 	2012-08-12

#singleInstance off
#noTrayIcon

stringCaseSense on
menu tray, icon, Malu Renamer.ico

; Global variables
filesList := ""

; Construct GUI
; Commands radio group
gui add, radio, x5 y7 vaddRadio gaddHandler checked, A&dd
gui add, radio, x5 y32 vtrimRadio gtrimHandler, &Trim
gui add, radio, x5 y58 vremoveRadio gremoveHandler, Remo&ve
gui add, radio, x260 y58 vchangeExtensionRadio gchangeExtensionHandler, Change extension to
gui add, radio, x5 y83 vreplaceRadio greplaceHandler, Repl&ace
gui add, radio, x5 y108 vcapitalizeRadio gcapitalizeHandler, Capitali&ze first letter
gui add, radio, x218 y108 vconvertCaseRadio gconvertCaseHandler, Convert all c&hars to
gui add, radio, x5 y133 vcreateNewNameRadio gcreateNewNameHandler, Create new name as

; Add
gui add, edit, x46 y4 w200 vaddEdit1 gaddHandler
guiControl focus, addEdit1
gui add, text, x251 y8 gaddHandler, at
gui add, edit, x264 y5 w40 vaddEdit2 gaddHandler number limit3, 0
gui add, upDown, Range0-255 gaddHandler
gui add, text, x308 y8 gaddHandler, chars from
gui add, button, x360 y5 w50 h20 vaddPosition gaddHandler, begin

; Trim
gui add, edit, x48 y29 w40 vtrimEdit1 gtrimHandler number limit3
gui add, upDown, Range0-255 gtrimHandler
gui add, text, x92 y32 gtrimHandler, chars after
gui add, edit, x146 y29 w40 vtrimEdit2 gtrimHandler number limit3, 0
gui add, upDown, Range0-255 gtrimHandler
gui add, text, x191 y32 gtrimHandler, chars from
gui add, button, x244 y29 w50 h20 vtrimPosition gtrimHandler, begin

; Remove
gui add, edit, x67 y55 w188 vremoveEdit gremoveHandler

; Change file extension
gui add, edit, x380 y55 w30 vchangeExtensionEdit gchangeExtensionHandler

; Replace
gui add, edit, x67 y80 w156 vreplaceEdit1 greplaceHandler
gui add, text, x229 y83 greplaceHandler, with
gui add, edit, x254 y80 w156 vreplaceEdit2 greplaceHandler

; Capitalize
gui add, checkbox, x120 y108 vofEveryWord gcapitalizeHandler, o&f every word

; Convert all chars to upper/lower case
gui add, button, x331 y105 w50 h20 vconvertCase gconvertCaseHandler, upper
gui add, text, x385 y108 gconvertCaseHandler, case

; Create new name
gui add, edit, x124 y130 w40 vcreateNewNameEdit1 gcreateNewNameHandler
gui add, edit, x165 y130 w48 vcreateNewNameEdit2 gcreateNewNameHandler number
gui add, upDown, Range0-99999 0x80 gcreateNewNameHandler
gui add, edit, x215 y130 w40 vcreateNewNameEdit3 gcreateNewNameHandler
gui add, text, x259 y133 gcreateNewNameHandler, padding
gui add, edit, x301 y130 w35 vcreateNewNameEdit4 gcreateNewNameHandler number limit2
gui add, upDown, Range0-99 gcreateNewNameHandler
gui add, text, x340 y133 gcreateNewNameHandler, chars with
gui add, edit, x392 y130 w18 vcreateNewNameEdit5 gcreateNewNameHandler limit1, 0

; Main controls
gui add, button, x5 y155 w60 h30 vclear gclear disabled, &Clear list
gui add, button, x84 y155 w60 h30 vpreview gpreview disabled, Pr&eview
gui add, checkbox, x146 y165 vlivePreview glivePreview disabled, Live previe&w
gui add, button, x240 y155 w170 h30 vrename grename disabled, &Rename

; Files list
gui add, listView, x415 y5 w500 h179 vlistView, Current name|New name
gui +resize +minSize415x189
gui show, w920 h189, Malu Renamer
sleep 100
guiControl, , addRadio, 1
return


; Labels
guiDropFiles:
	loop parse, A_GuiEvent, `n
	{
		addFile(A_LoopField)
	}

	enableControls()
	return

guiSize:
	guiControl move, listView, % "w" A_GuiWidth - 420  " h" A_GuiHeight - 10
	LV_ModifyCol(1, (A_GuiWidth - 441) / 2)
	LV_ModifyCol(2, (A_GuiWidth - 441) / 2)
	return

guiClose:
	exitApp
	return

clear:
	clear()
	return

preview:
	work(false)
	return

rename:
	work()
	return

livePreview:
	maybePreview()
	return

addHandler:
	if (A_GuiControl == "addRadio") {
		guiControl focus, addEdit1
	} else if (A_GuiControl == "addPosition") {
		changeControlCaption(A_GuiControl)
	}

	guiControl, , addRadio, 1
	maybePreview()
	return

trimHandler:
	if (A_GuiControl == "trimRadio") {
		guiControl focus, trimEdit1
	} else if (A_GuiControl == "trimPosition") {
		changeControlCaption(A_GuiControl)
	}

	guiControl, , trimRadio, 1
	maybePreview()
	return

removeHandler:
	if (A_GuiControl == "removeRadio") {
		guiControl focus, removeEdit
	}

	guiControl, , removeRadio, 1
	maybePreview()
	return

changeExtensionHandler:
	if (A_GuiControl == "changeExtensionRadio") {
		guiControl focus, changeExtensionEdit
	}

	guiControl, , changeExtensionRadio, 1
	maybePreview()
	return

replaceHandler:
	if (A_GuiControl == "replaceRadio") {
		guiControl focus, replaceEdit1
	}

	guiControl, , replaceRadio, 1
	maybePreview()
	return

capitalizeHandler:
	guiControl, , capitalizeRadio, 1
	maybePreview()
	return

convertCaseHandler:
	if (A_GuiControl == "convertCase") {
		changeControlCaption(A_GuiControl)
	}

	guiControl, , convertCaseRadio, 1
	maybePreview()
	return

createNewNameHandler:
	if (A_GuiControl == "createNewNameRadio") {
		guiControl focus, createNewNameEdit1
	}

	guiControl, , createNewNameRadio, 1
	maybePreview()
	return


; Functions
addFile(filePath)
{
	global filesList
	splitPath filePath, fileNameREMOVETHIS
	LV_Add("", fileNameREMOVETHIS)

	if (filesList == "") {
		filesList := filePath
	} else {
		filesList .= "`n" . filePath
	}
}

clear()
{
	global filesList
	filesList := ""
	LV_Delete()
	disableControls()
}

enableControls()
{
	guiControl enable, clear
	guiControl enable, preview
	guiControl enable, livePreview
	guiControl, , livePreview, 1
	guiControl enable, rename
}

disableControls()
{
	guiControl disable, clear
	guiControl disable, preview
	guiControl disable, livePreview
	guiControl disable, rename
}

changeControlCaption(control)
{
	guiControlGet controlCaption, , %A_GuiControl%

	if (controlCaption == "begin") {
		guiControl, , %A_GuiControl%, end
	} else if (controlCaption == "end") {
		guiControl, , %A_GuiControl%, begin
	} else if (controlCaption == "upper") {
		guiControl, , %A_GuiControl%, lower
	} else if (controlCaption == "lower") {
		guiControl, , %A_GuiControl%, upper
	}
}

pad(input, width, paddingCharacter)
{
	padding := ""

	loop % width - strLen(input)
	{
		padding .= paddingCharacter
	}

	return padding . input
}

maybePreview()
{
	guiControlGet livePreview, , livePreview

	if (livePreview) {
		work(false)
	}
}

work(actuallyRename = true)
{
	global filesList
	guiControlGet addRadio, , addRadio

	if (addRadio) {
		; Validation
		guiControlGet addEdit2, , addEdit2

		if addEdit2 is not digit
		{
			trayTip, , Invalid position!
			return
		}

		; Validation passed!
		guiControlGet addEdit1, , addEdit1
		guiControlGet addPosition, , addPosition

		loop parse, filesList, `n, `r
		{
			splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive

			if (addPosition == "begin") {
				newFileName := regExReplace(fileNameWithoutExtension, "^(.{" . addEdit2 . "})(.*)$", "$1" . addEdit1 . "$2")
			} else {
				newFileName := regExReplace(fileNameWithoutExtension, "^(.*)(.{" . addEdit2 . "})$", "$1" . addEdit1 . "$2")
			}

			LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
		}
	} else {
		guiControlGet trimRadio, , trimRadio

		if (trimRadio) {
			; Validations
			guiControlGet trimEdit1, , trimEdit1

			if trimEdit2 is not digit
			{
				trayTip, , Invalid position!
				return
			}

			guiControlGet trimEdit2, , trimEdit2

			if trimEdit2 is not digit
			{
				trayTip, , Invalid position!
				return
			}

			; Validation passed!
			guiControlGet trimPosition, , trimPosition

			loop parse, filesList, `n, `r
			{
				splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive

				if (trimPosition == "begin") {
					newFileName := regExReplace(fileNameWithoutExtension, "^(.{" . trimEdit2 . "})(.{" . trimEdit1 . "})(.*)$", "$1$3")
				} else {
					newFileName := regExReplace(fileNameWithoutExtension, "^(.*)(.{" . trimEdit1 . "})(.{" . trimEdit2 . "})$", "$1$3")
				}

				LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
			}
		} else {
			guiControlGet removeRadio, , removeRadio

			if (removeRadio) {
				guiControlGet removeEdit, , removeEdit

				loop parse, filesList, `n, `r
				{
					splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive
					newFileName := regExReplace(fileNameWithoutExtension, removeEdit, "")
					LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
				}
			} else {
				guiControlGet replaceRadio, , replaceRadio

				if (replaceRadio) {
					guiControlGet replaceEdit1, , replaceEdit1
					guiControlGet replaceEdit2, , replaceEdit2

					loop parse, filesList, `n, `r
					{
						splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive
						stringReplace newFileName, fileNameWithoutExtension, %replaceEdit1%, %replaceEdit2%, all
						LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
					}
				} else {
					guiControlGet changeExtensionRadio, , changeExtensionRadio

					if (changeExtensionRadio) {
						guiControlGet changeExtensionEdit, , changeExtensionEdit

						loop parse, filesList, `n, `r
						{
							splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive
							LV_Modify(A_Index, "Col2", fileNameWithoutExtension . "." . changeExtensionEdit)
						}
					} else {
						guiControlGet capitalizeRadio, , capitalizeRadio

						if (capitalizeRadio) {
							guiControlGet ofEveryWord, , ofEveryWord

							loop parse, filesList, `n, `r
							{
								splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive

								if (ofEveryWord) {
									newFileName := ""
									upperCaseNextLetter := false

									loop parse, fileNameWithoutExtension
									{
										if (A_Index == 1 || upperCaseNextLetter) {
											stringUpper upperCaseCharacter, A_LoopField
											upperCaseNextLetter := false
											newFileName .= upperCaseCharacter
										} else {
											newFileName .= A_LoopField
										}

										if (A_LoopField == A_Space) {
											upperCaseNextLetter := true
										}
									}
								} else {
									stringLeft firstLetter, fileNameWithoutExtension, 1
									stringUpper firstLetterUpperCase, firstLetter, T
									stringTrimLeft trimmedFileNameWithoutExtension, fileNameWithoutExtension, 1
									newFileName := firstLetterUpperCase . trimmedFileNameWithoutExtension
								}

								LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
							}
						} else {
							guiControlGet convertCaseRadio, , convertCaseRadio

							if (convertCaseRadio) {
								guiControlGet convertCase, , convertCase

								loop parse, filesList, `n, `r
								{
									splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive

									if (convertCase == "upper") {
										stringUpper newFileName, fileNameWithoutExtension
									} else {
										stringLower newFileName, fileNameWithoutExtension
									}

									LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
								}
							} else {
								guiControlGet createNewNameRadio, , createNewNameRadio

								if (createNewNameRadio) {
									; Validations
									guiControlGet createNewNameEdit2, , createNewNameEdit2

									if createNewNameEdit2 is not digit
									{
										trayTip, , Invalid position!
										return
									}

									guiControlGet createNewNameEdit4, , createNewNameEdit4

									if createNewNameEdit4 is not digit
									{
										if createNewNameEdit4 is not space
										{
											if (createNewNameEdit4 != "") {
												guiControl, , createNewNameEdit4, 0
											}
										}
									}

									; Validations passed!
									guiControlGet createNewNameEdit1, , createNewNameEdit1
									guiControlGet createNewNameEdit3, , createNewNameEdit3
									guiControlGet createNewNameEdit5, , createNewNameEdit5

									loop parse, filesList, `n, `r
									{
										splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive

										if (createNewNameEdit4 == 0) {
											newFileName := createNewNameEdit1 . createNewNameEdit2 + A_Index - 1 . createNewNameEdit3
										} else {
											newFileName := createNewNameEdit1 . pad(createNewNameEdit2 + A_Index - 1, createNewNameEdit4, createNewNameEdit5) . createNewNameEdit3
										}

										LV_Modify(A_Index, "Col2", newFileName . "." . fileExtension)
									}
								}
							}
						}
					}
				}
			}
		}
	}

	if (actuallyRename) {
		newFilesList := ""

		loop parse, filesList, `n, `r
		{
			splitPath A_LoopField, fileName, fileDirectory, fileExtension, fileNameWithoutExtension, fileDrive
			LV_GetText(oldFileName, A_Index, 1)
			LV_GetText(newFileName, A_Index, 2)

			if (newFileName != oldFileName) {
				fileMove %fileDirectory%\%oldFileName%, %fileDirectory%\%newFileName%
			}

			if (newFilesList == "") {
				newFilesList := fileDirectory . "\" . newFileName
			} else {
				newFilesList .= "`n" . fileDirectory . "\" . newFileName
			}
		}

		clear()

		loop parse, newFilesList, `n
		{
			addFile(A_LoopField)
		}

		enableControls()
	}
}
