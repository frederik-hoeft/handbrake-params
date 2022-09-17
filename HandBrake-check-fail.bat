@echo off
set exitcode=%errorlevel%
if errorlevel 1 (
	start /WAIT powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('RIP :/', 'HandBrakeCLI failed', 'OK', [System.Windows.Forms.MessageBoxIcon]::Error);}"
	rem break the continuation chain by producing non-zero exit code :P
	rem throw will be an undefined label
	goto throw
)