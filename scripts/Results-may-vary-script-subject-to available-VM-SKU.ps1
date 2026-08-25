<#
.SYNOPSIS
    Phase 3: Deploys Entra ID joined Session Hosts into the AVD Host Pool.
.AUTHOR
    Ananda Mohite
#>

# Note RUN this script at your OWN risk. QUOTA LIMIT, FATAL PROVISIONING in my case , Used Azure Portal to get available SKU sizes VM. 




# 1. Parameters & Configuration

$Location          = "eastus"
$RG_Management     = "rg-avd-management"
$RG_Network        = "rg-avd-network"
$RG_Compute        = "rg-avd-compute"
$VNetName          = "vnet-avd-prod-01"
$SubnetName        = "snet-avd-hosts"
$HostPoolName      = "hp-avd-pooled-01"

$VMNamePrefix      = "vm-avd-sh"
$VMCount           = 2
$VMSize            = "Standard_D2s_v5"
$AdminUsername     = "localadmin"
$AdminPassword     = ConvertTo-SecureString "P@ssw0rd2026!AVD" -AsPlainText -Force

$Tags = @{
    "Environment"  = "Production"
    "WorkloadName" = "AVD-Enterprise-LandingZone"
    "Owner"        = "Ananda Mohite"
    "CostCenter"   = "CC-IT-AVD-01"
}

# 
# 2. Provison Compute Resource Group

if (-not (Get-AzResourceGroup -Name $RG_Compute -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $RG_Compute -Location $Location -Tag $Tags | Out-Null
    Write-Host "Created Resource Group: $RG_Compute" -ForegroundColor Green
}


# 3. Generate REGISTRATION TOKEN FOR Host Pool

$TokenExpiration = (Get-Date).AddHours(2).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
$RegistrationInfo = New-AzWvdRegistrationInfo `
    -ResourceGroupName $RG_Management `
    -HostPoolName $HostPoolName `
    -ExpirationTime $TokenExpiration

$RegistrationToken = $RegistrationInfo.Token
Write-Host "Host Pool Registration Token Generated." -ForegroundColor Green


# 4. Fetch Network Subnet Reference

$Subnet = Get-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -VirtualNetwork (Get-AzVirtualNetwork -ResourceGroupName $RG_Network -Name $VNetName)


# 5. Deploy Session Host VMS & ENTRA ID Join Extension

for ($i = 0; $i -lt $VMCount; $i++) {
    $VMName = "$VMNamePrefix-$i"
    $NICName = "nic-$VMName"

    # Create Network Interface
    $NIC = New-AzNetworkInterface `
        -ResourceGroupName $RG_Compute `
        -Name $NICName `
        -Location $Location `
        -SubnetId $Subnet.Id `
        -Tag $Tags

    # VM Configuration
    $VMConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize |
        Set-AzVMOperatingSystem -Windows -ComputerName $VMName -Credential (New-Object System.Management.Automation.PSCredential($AdminUsername, $AdminPassword)) |
        Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "office-365" -Skus "win11-23h2-avd-m365" -Version "latest" |
        Add-AzVMNetworkInterface -Id $NIC.Id

    # Create VM
    New-AzVM -ResourceGroupName $RG_Compute -Location $Location -VM $VMConfig -Tag $Tags | Out-Null
    Write-Host "Deployed VM: $VMName" -ForegroundColor Green

    # Enable Entra ID Join Extension
    Set-AzVMExtension `
        -ResourceGroupName $RG_Compute `
        -VMName $VMName `
        -Name "AADLoginForWindows" `
        -Publisher "Microsoft.Azure.ActiveDirectory" `
        -ExtensionType "AADLoginForWindows" `
        -TypeHandlerVersion "1.0" `
        -Location $Location | Out-Null

    Write-Host "Entra ID Join configured on $VMName" -ForegroundColor Green
}

Write-Host "Phase 3 Session Host Deployment Complete!" -ForegroundColor Cyan


