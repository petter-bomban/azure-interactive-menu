$ErrorActionPreference = "Stop"

## Imports
. .\helpers.ps1
. .\main_funcs.ps1
. .\menu.ps1
. .\global_variables.ps1


## Main menu loop
function Start-AIM {

    while ($true) {

        Get-ASCIIText -MenuName "Main Menu"

        Get-StartMenu
    }

}

## Start session log
Start-Transcript -Path $FullLogPath -NoClobber

## Start main application
Start-AIM

## End session log
Stop-Transcript
