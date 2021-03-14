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
        ## Setup vm credentials
        ##################################################

        $pw = ConvertTo-SecureString $conf.vm_acc_pwd -AsPlainText -Force -ErrorAction Stop
        $cred = New-Object System.Management.Automation.PSCredential ($conf.vm_acc_name, $pw)


        ## Resource Group
        ##################################################
        Write-Host "Resource group"
        $rg_args = @{
            Name        = $conf.rg_name
            Location    = $conf.location
            ErrorAction = "Stop"
        }
        $rg_obj = New-AzResourceGroup @rg_args
        $resources_created += $rg_obj

        ## Subnet
        ##################################################
        Write-Host "Subnet"
        $subnet_args = @{
            Name          = $conf.subnet_name
            AddressPrefix = $conf.ip_subnet
            ErrorAction   = "Stop"
        }
        $subnet_obj = New-AzVirtualNetworkSubnetConfig @subnet_args
        $resources_created += $subnet_obj

        ## VNET
        ##################################################
        Write-Host "VNET"
        $vnet_args = @{
            ResourceGroupName = $conf.rg_name
            Location          = $conf.location
            Name              = $conf.vnet_name
            AddressPrefix     = $conf.ip_range
            Subnet            = $subnet_obj
            ErrorAction       = "Stop"
        }
        $vnet_obj = New-AzVirtualNetwork @vnet_args
        $resources_created += $vnet_obj

        ## VM
        ##################################################
        ## Baseline VM
        Write-Host "Base VM"
        $vm_args = @{
            Name               = $conf.vm_name
            ResourceGroupName  = $conf.rg_name
            Location           = $conf.location
            VirtualNetworkName = $conf.vnet_name
            SubnetName         = $conf.subnet_name
            Size               = $conf.vm_size
            Credential         = $cred
            ErrorAction        = "Stop"
        }
        $vm_obj = New-AzVM @vm_args 
        $resources_created += $vm_obj

        ## Set OS
        Write-Host "Set OS"
        $vm_os_args = @{
            VM               = $vm_obj
            Windows          = $true
            ComputerName     = $Conf.vm_name
            ProvisionVMAgent = $true
            EnableAutoUpdate = $true
            Credential       = $cred
            ErrorAction      = "Stop"
        }
        $vm_os_obj = Set-AzVMOperatingSystem @vm_os_args

        ## Set NIC
        Write-Host "Set NIC"
        $vm_id = (Get-AzVM -Name $conf.vm_name).Id 
        $vm_nic_args = @{
            VM          = $vm_os_obj
            Id          = $vm_id
            ErrorAction = "Stop"
        }
        Add-AzVMNetworkInterface @vm_nic_args

        ## Set OS Image
        Write-Host "Set image"
        $vm_image_args = @{
            VM            = $vm_obj
            PublisherName = "MicrosoftWindowsServer"
            Offer         = $conf.offer
            Skus          = $conf.sku
            Version       = "latest"
            ErrorAction   = "Stop"
        }
        $vm_image = Set-AzVMSourceImage @vm_image_args

    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-host $ErrorMessage -ForegroundColor red

        ## Start rollback
        foreach ($resource in $resources_created) {

            Write-Host "ROLLBACK $resource" -ForegroundColor Yellow
            $resource | Remove-AzResource -Force
        }
        
        Read-Host "Rollback completed, press any key to return"
        return
    }

    ## TODO: File export for easy rollback
    ## TODO: Rollback in its own function
    ## TODO: VM Creation and config in its own function
    $resources_created 

    Read-Host "Function completed, press any key to return"


} 
