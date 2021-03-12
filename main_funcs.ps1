function New-AzureBaselineEnvironment ($Conf) {

    Write-Host "New-AzureBaselineEnvironment"

    Write-Host "Setting up a new baseline environment.."

    <#
    $ComputeObject = [PSCustomObject]@{
            rg_name         = $null
            location        = $null
            vnet_name       = $null
            subnet_name     = $null
            ip_range        = "10.0.0.0/16"
            ip_subnet       = "10.0.1.0/24"
            ip_nsg          = $null
            vmn_ame         = $null
            vm_size         = "Standard_F2"
            vm_type         = $null
            storage_acc     = "[auto]"
            offer           = "[auto]"
            sku             = "[auto]"
    }#>

    ## Storing created resources in case of a failure--will use for rollback
    $resources_created = @()

    try {
        ## Resource Group
        ##################################################
        $rg_args = @{
            Name = $Conf.rg_name
            Location = $conf.location
        }
        $rg_obj = New-AzResourceGroup @rg_args
        $resources_created += $rg_obj

        ## Subnet
        ##################################################
        $subnet_args = @{
            Name = $conf.subnet_name
            AddressPrefix = $conf.ip_subnet
        }
        $subnet_obj = New-AzVirtualNetworkSubnetConfig @subnet_args
        $resources_created += $subnet_obj

        ## TODO...
    }
    catch {
        $ErrorMessage = $_.Exception.Message

        ## Start rollback
        foreach ($resource in $resources_created) {

            Write-Host "ROLLBACK $resource"
            ## TODO
        }
    }

    $resources_created 


} 
