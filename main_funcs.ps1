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
            Name     = $Conf.rg_name
            Location = $conf.location
        }
        $rg_obj = New-AzResourceGroup @rg_args
        $resources_created += $rg_obj

        ## Subnet
        ##################################################
        $subnet_args = @{
            Name          = $conf.subnet_name
            AddressPrefix = $conf.ip_subnet
        }
        $subnet_obj = New-AzVirtualNetworkSubnetConfig @subnet_args
        $resources_created += $subnet_obj

        ## VNET
        ##################################################
        $vnet_args = @{
            ResourceGroupName = $conf.rg_name
            Location          = $conf.location
            Name              = $conf.vnet_name
            AddressPrefix     = $conf.ip_range
            Subnet            = $subnet_obj
        }
        $vnet_obj = New-AzVirtualNetwork @vnet_args
        $resources_created += vnet_obj

        ## VM
        ##################################################
        $vm_args = @{
            Name               = $conf.vm_name
            ResourceGroupName  = $conf.rg_name
            Location           = $conf.location
            VirtualNetworkName = $conf.vnet_name
            SubnetName         = $conf.subnet_name
            Size               = $conf.vm_size
        }
        $vm_obj = New-AzVM @vm_args
        $resources_created += $vm_obj
        

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
