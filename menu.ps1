

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
            rg_name         = $null
            location        = $null
            vnet_name       = $null
            subnet_name     = $null
            ip_subnet       = "10.0.1.0/24"
            ip_range        = "10.0.0.0/16"
            ip_nsg          = $null
            vm_name         = $null
            vm_size         = "Standard_F2"
            vm_type         = "Server"
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
    $ComputeObject.storage_acc  = "$($ComputeObject.vm_name)_store"

    ## VM name length
    $vmname_length = ($ComputeObject.vm_name).Length
    while (($vmname_length  -gt 15) -or ($vmname_length -le 0)) {
        Write-Host ""
        Write-Host "VM name is too long. or empty. Maximum 15 characters allowed."
        Write-Host "Current name '$($ComputeObject.vm_name)' is $vmname_length characters long."
        Write-Host ""
        
        $ComputeObject.vmn_ame = Read-Host "Enter a new name: "

        $vmname_length = ($ComputeObject.vm_name).Length
    }

    ## VM Type
    switch ($ComputeObject.vm_type) {

        "D" {
            $ComputeObject.vm_type   = "Desktop"
            $ComputeObject.offer    = "windows-10-20h2-vhd-server-prod-stage"
            $ComputeObject.sku      = "datacenter-core-20h2-with-containers-smalldisk"
        }
        default {
            $ComputeObject.vm_type   = "Server"
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
    New-AzureBaselineEnvironment -Conf $ComputeObject
}

function Connect-ToAzAzure {

    Get-ASCIIText

    $Global:session = Connect-AzAccount
}

Function Remove-ResourceGroup {

    $rg_name = Read-Host "Type in Resource Group name"

    Write-Warning "THIS WILL DELETE EVERYTHING CONTAINED WITHIN THE RESOURCE GROUP"
    $proceed = Read-Host "Proceed? [Y/N]"

    if ($proceed -ne "Y") {
        Write-Host "Will not proceed with resource group deletion"
        Read-Host "Press Any Key to return..."
        return
    }

    ## TODO: Do this as job
    try {
        Write-Host "Please wait, this will take a while..."
        $rg = Get-AzResourceGroup -Name $rg_name
        $rg | Remove-AzResourceGroup -Force -Confirm:$false
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-host $ErrorMessage -ForegroundColor red

        Read-Host "Return to main menu..."
        return
    }
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
    [4] Remove Resource Group with all sub-resources

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
        3 {
            #
        }
        4 {
            Remove-ResourceGroup
        }
        "q" {
            exit
        }
    }
}


function Get-AzureADMenu {

    # TODO
}