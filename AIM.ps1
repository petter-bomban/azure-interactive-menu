## Imports
. .\helpers.ps1
. .\main_funcs.ps1
. .\menu.ps1

## Main menu loop
function Start-AIM {

    while ($true) {

        Get-ASCIIText

        Get-StartMenu
    }

}

Start-AIM
