## Global configuration variables

$Global:session = ""

$LogFolder = Join-Path -Path $PSScriptRoot -ChildPath "session_logs"
$LogName   = "AIM-Log_$(Get-Date -Format 'yyyy-MM-dd_hh-mm-ss').txt"

$Global:FullLogPath = Join-Path -Path $LogFolder -ChildPath $LogName
