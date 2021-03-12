

#############################################################
## Menu Functions
#############################################################

function Get-AzureEnvMenu ($ComputeObject = $false) {

    ## Initial information gathering
    ##################################################
    
    Get-ASCIIText

    ## Set default values
    if (!($ComputeObject)) {
        $ComputeObject = [PSCustomObject]@{
            rg              = $null
            location        = $null
            vnet            = $null
            subnet          = $null
            ip_range        = "10.0.0.0/16"
            ip_subnet       = "10.0.1.0/24"
            ip_nsg          = $null
            vmname          = $null
            vmsize          = "Standard_F2"
            vmtype          = $null
            storage_acc     = "[auto]"
            offer           = "[auto]"
            sku             = "[auto]"
        }
    }

    Write-ObjectToHost $ComputeObject

    Write-Host "You will now be asked to configure the above variables.
    Some properties have default values that can be left empty.`r`n"

    ## Loop through each property in the object and ask for a value
    ## NOTE: This should become a helper function if same logic is needed elsewhere
    foreach ($property in $ComputeObject.PsObject.Properties) {

        ## Skip values that are set automatically later on
        if ($property.Value -eq "[auto]") {
            continue
        }

        ## Set desired property value and ensure it is not empty
        $value = $null
        while (($value -eq $null) -or (Confirm-IfWhitespace($value))) {

            $value = Read-Host "Set property - $($property.name)[$($property.value)]"

            ## If a property has a default value,
            # and the $value variable is empty, skip to allow default to subsist
            if (($property.value -ne $null) -and (Confirm-IfWhitespace($value))) {

                $value = $property.value
            }
        }

        $ComputeObject.($property.name) = $value
    }

    ## Verification
    ##################################################

    ## Set storage account name
    $ComputeObject.storage_acc  = "$($ComputeObject.vmname)_store"

    ## VM name length
    $vmname_length = ($ComputeObject.vmname).Length
    while (($vmname_length  -gt 15) -or ($vmname_length -le 0)) {
        Write-Host ""
        Write-Host "VM name is too long. or empty. Maximum 15 characters allowed."
        Write-Host "Current name '$($ComputeObject.vmname)' is $vmname_length characters long."
        Write-Host ""
        
        $ComputeObject.vmname = Read-Host "Enter a new name: "

        $vmname_length = ($ComputeObject.vmname).Length
    }

    ## VM Type
    switch ($ComputeObject.vmtype) {

        "D" {
            $ComputeObject.vmtype   = "Desktop"
            $ComputeObject.offer    = "windows-10-20h2-vhd-server-prod-stage"
            $ComputeObject.sku      = "datacenter-core-20h2-with-containers-smalldisk"
        }
        default {
            $ComputeObject.vmtype   = "Server"
            $ComputeObject.offer    = "WindowsServer"
            $ComputeObject.sku      = "2019-Datacenter"
        }
    }

    ## Confirmation
    ##################################################

    Write-ObjectToHost -Object $ComputeObject

    $start = $false
    $confirm = $false
    while (!($confirm)) {

        $confirm = Read-Host "Confirm the configuration displayed above.
        Selecting N will allow you to re-configure.
        (Y/N): "

        switch ($confirm) {

            "Y" {
                $confirm = $true
                $start = $true
            }
            "N" {
                $confirm = $true
                $start = $false
            }
            default {
                $confirm = $false
            }
        }
    }

    if ($start -eq $false) {
        return Get-AzureEnvMenu -ComputeObject $ComputeObject
    }


    ## Job Start
    ##################################################
    read-host "job start..."
    # TODO
}

function Connect-ToAzAzure {

    Get-ASCIIText

    $Global:session = Connect-AzAccount

    $Global:session

    read-host ""

}
 
function Get-StartMenu {

    if ($global:session) {

        Write-Host "Connected to Azure account $($session.Context.Account.Id)`r`n" -ForegroundColor green
    }

    $Choice = Read-Host "Please select an option using the number.
    [0] Authenticate to Azure
    [1] Create new Azure baseline environment
    [2] Add Virtual Machine(s) to existing environment
    [3] Add Network[s] to existing environment
    [4] Configure Azure AD DS

    [q] Exit

Selection: "

    switch ($Choice) {

        0 {
            Connect-ToAzAzure
        }
        1 {
            Get-AzureEnvMenu
        }
        2 {
            # ...
        }
        "q" {
            exit
        }
    }
}


function Get-AzureADMenu {

    # TODO
}