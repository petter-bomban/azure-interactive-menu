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
            Name        = $conf.rg_name
            Location    = $conf.location
            ErrorAction = "Stop"
        }
        $rg_obj = New-AzResourceGroup @rg_args
        $resources_created += $rg_obj

        ## Subnet
        ##################################################
        $subnet_args = @{
            Name          = $conf.subnet_name
            AddressPrefix = $conf.ip_subnet
            ErrorAction   = "Stop"
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
            ErrorAction       = "Stop"
        }
        $vnet_obj = New-AzVirtualNetwork @vnet_args
        $resources_created += vnet_obj

        ## VM
        ##################################################
        ## Baseline VM
        $vm_args = @{
            Name               = $conf.vm_name
            ResourceGroupName  = $conf.rg_name
            Location           = $conf.location
            VirtualNetworkName = $conf.vnet_name
            SubnetName         = $conf.subnet_name
            Size               = $conf.vm_size
            ErrorAction        = "Stop"
        }
        $vm_obj = New-AzVM @vm_args
        $resources_created += $vm_obj

        ## Set OS
        $vm_os_args = @{
            VM               = $vm_obj
            Windows          = $true
            ComputerName     = $Conf.vm_name
            ProvisionVMAgent = $true
            EnableAutoUpdate = $true
            ErrorAction      = "Stop"
        }
        Set-AzVMOperatingSystem @vm_os_args

        ## Set NIC
        $vm_nic_args = @{
            VM          = $vm_obj
            ErrorAction = "Stop"
        }
        Add-AzVMNetworkInterface @vm_nic_args

        ## Set OS Image
        $vm_image_args = @{
            VM            = $vm_obj
            PublisherName = "MicrosoftWindowsServer"
            Offer         = $conf.offer
            Skus          = $conf.sku
            Version       = "latest"
            ErrorAction   = "Stop"
        }
        $vm_image = Set-AzVMSourceImage @vm_image_args

        ## Finalize creation
        $vm_final_args = @{
            ResourceGroupName = $conf.rg_name
            Location          = $conf.location
            VM                = $vm_image
            ErrorAction       = "Stop"
        }

        $vm_final = New-AzVM @vm_final_obj
        $resources_created += $vm_final

    }
    catch {
        $ErrorMessage = $_.Exception.Message

        ## Start rollback
        foreach ($resource in $resources_created) {

            Write-Host "ROLLBACK $resource"
            $resource | Remove-AzResource -Force
        }
    }

    $resources_created 


} 
