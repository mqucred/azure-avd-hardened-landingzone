

# 1. Parameters & Tags

$Location          = "eastus"
$RG_Network        = "rg-avd-network"
$VNetName          = "vnet-avd-prod-01"
$VNetAddressPrefix = "10.1.0.0/16"
$SubnetName        = "snet-avd-hosts"
$SubnetPrefix      = "10.1.1.0/24"

$Tags = @{
    "Environment"  = "Production"
    "WorkloadName" = "AVD-Enterprise-LandingZone"
    "Owner"        = "Ananda Mohite"
    "CostCenter"   = "CC-IT-AVD-01"
}


# 2. Provision Network Resource Group
# 
if (-not (Get-AzResourceGroup -Name $RG_Network -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $RG_Network -Location $Location -Tag $Tags | Out-Null
    Write-Host "Created Resource Group: $RG_Network" -ForegroundColor Green
}


# 3. Deploy Virtual Network & Subnet

$SubnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix $SubnetPrefix

$VNet = New-AzVirtualNetwork `
    -ResourceGroupName $RG_Network `
    -Name $VNetName `
    -Location $Location `
    -AddressPrefix $VNetAddressPrefix `
    -Subnet $SubnetConfig `
    -Tag $Tags

Write-Host "Virtual Network $VNetName and Subnet $SubnetName deployed successfully!" -ForegroundColor Cyan