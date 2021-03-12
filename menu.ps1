

#############################################################
## Menu Functions
#############################################################

function Get-AzureEnvMenu () {

    ## Initial information gathering
    ##################################################
    
    Get-ASCIIText

    $ComputeObject = [PSCustomObject]@{
        rg              = $null
        location        = $null
        vnet            = $null
        subnet          = $null
        ip_range        = $null
        ip_subnet       = $null
        ip_nsg          = $null
        vmname          = $null
        vmsize          = $null
        vmtype          = $null
        storage_acc     = "[automatic]"
        offer           = "[automatic]"
        sku             = "[automatic]"
    }

    Write-ObjectToHost $ComputeObject
    Write-Host "You will now be asked to configure the above variables.
    "

    $ComputeObject.rg           = Read-Host "Resource Group name: "
    $ComputeObject.location     = Read-Host "Geographic Location: "
    $ComputeObject.vnet         = Read-Host "Virtual Network name: "
    $ComputeObject.subnet       = Read-Host "Subnet name: "
    $ComputeObject.ip_range     = Read-Host "Enter IP Range for Customer (default 10.0.0.0/16): "
    $ComputeObject.ip_subnet    = Read-Host "Enter primary subnet (default 10.0.1.0/24): "
    $ComputeObject.ip_nsg       = Read-Host "Network Security Group name: "

    $ComputeObject.vmsize       = Read-Host "VM Size (default Standard_F2): "
    $ComputeObject.vmname       = Read-Host "VM Name (15 character limit): "
    $ComputeObject.vmtype       = Read-Host "Desktop or Server? (D/S, default S): "
    
    $ComputeObject.storage_acc  = "{0}{1}" -f $ComputeObject.vmname, "_store"

    ## Verification
    ##################################################

    ## ip range default
    if (Confirm-IfWhitespace($ComputeObject.ip_range)){
        $ComputeObject.ip_range = "10.0.0.0/16"
    }
    ## ip subnet default
    if (Confirm-IfWhitespace($ComputeObject.ip_subnet)) {
        $ComputeObject.ip_subnet = "10.0.1.0/24"
    }
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
    ## VM Size
    if (Confirm-IfWhitespace($ComputeObject.vmsize)) {
        $ComputeObject.vmsize = "Standard_F2"
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
    while (!($confirm)) {

        $confirm = Read-Host "Confirm the configuration displayed above.
        Selecting N will exit back to start menu.
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
        return
    }


    ## Job Start
    ##################################################
    read-host "job start..."
    # TODO
}

 
function Get-StartMenu {

    $Choice = Read-Host "Please select an option using the number.

    [1] Create new Azure baseline environment
    [2] Add Virtual Machine(s) to existing environment
    [3] Add Network[s] to existing environment
    [4] Configure Azure AD DS
    
    Selection: "

    switch ($Choice) {

        1 {
            Get-AzureEnvMenu
        }
        2 {
            # ...
        }
    }
}


function Get-AzureADMenu {

    # TODO
}