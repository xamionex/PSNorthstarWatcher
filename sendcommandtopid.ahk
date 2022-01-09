#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if A_Args.Count() = 2
{
	pid := A_Args[1]
	input := A_Args[2]
	ControlSend,,%input%{Enter}, ahk_pid %pid%
} else{
	throw "More than 2 arguments supplied. Syntax: sendcommandtopid.exe PID COMMAND"
}
