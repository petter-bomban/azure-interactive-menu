#############################################################
## Helper Functions
#############################################################

function Confirm-IfWhitespace ($str) {

    $str = "$str"
    if ([string]::IsNullOrWhiteSpace($str) -or [string]::IsNullOrEmpty($str)) {

        return $true
    }
    return $false
}

function Get-ASCIIText {

    $AsciiArt = @'
     ___  ________  ___
    / _ \|_   _|  \/  |
   / /_\ \ | | | .  . |
   |  _  | | | | |\/| |
   | | | |_| |_| |  | |
   \_| |_/\___/\_|  |_/  
  Azure Interactive Menu
           v0

'@

    Clear-Host
    Write-Host $AsciiArt
}

function Write-ObjectToHost ($object) {

    $object = $object | Format-List | Out-String
    Write-Host "$object"
}
