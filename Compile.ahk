#noTrayIcon

loop *.ahk
{
	if (A_LoopFileName != A_ScriptName) {
		splitPath A_LoopFileLongPath, , , , scriptNameWithouExtension
		break
	}
}

process close, %scriptNameWithouExtension%.exe
process waitClose, %scriptNameWithouExtension%.exe
runWait C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe /in "%scriptNameWithouExtension%.ahk" /icon "%scriptNameWithouExtension%.ico", , hide useErrorLevel
