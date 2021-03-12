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
     _                                             
    / \    _____   _ _ __ ___                      
   / _ \  |_  / | | | '__/ _ \                     
  / ___ \  / /| |_| | | |  __/                     
 /_/_  \_\/___|\__,_|_|  \___|     _   _           
 |_ _|_ __ | |_ ___ _ __ __ _  ___| |_(_)_   _____ 
  | || '_ \| __/ _ \ '__/ _` |/ __| __| \ \ / / _ \
  | || | | | ||  __/ | | (_| | (__| |_| |\ V /  __/
 |___|_| |_|\__\___|_|  \__,_|\___|\__|_| \_/ \___|
 |  \/  | ___ _ __  _   _                          
 | |\/| |/ _ \ '_ \| | | |                         
 | |  | |  __/ | | | |_| |                         
 |_|  |_|\___|_| |_|\__,_|                         

'@

    Clear-Host
    Write-Host $AsciiArt
}

function Write-ObjectToHost ($object) {

    $object = $object | Format-List | Out-String
    Write-Host "
    $object"
}
