# Fetch Host Pool Token
$Token = (Get-AzWvdHostPool -ResourceGroupName "rg-avd-management" -Name "hp-avd-pooled-01").RegistrationInfoToken

# Install Entra ID Join Extension directly on both hosts
$VMs = @("vm-avd-sh-0", "vm-avd-sh-1")
foreach ($VM in $VMs) {
    Set-AzVMExtension `
        -ResourceGroupName "rg-avd-compute" `
        -VMName $VM `
        -Name "AADLoginForWindows" `
        -Publisher "Microsoft.Azure.ActiveDirectory" `
        -ExtensionType "AADLoginForWindows" `
        -TypeHandlerVersion "1.0" `
        -Location "eastus"
}




New-AzPublicIpAddress `
  -ResourceGroupName "rg-avd-network" `
  -Name "pip-nat-avd-prod-01" `
  -Location "eastus" `
  -AllocationMethod Static `
  -Sku Standard




  # Create NAT Gateway
$pip = Get-AzPublicIpAddress -ResourceGroupName "rg-avd-network" -Name "pip-nat-avd-prod-01"
$natGateway = New-AzNatGateway `
  -ResourceGroupName "rg-avd-network" `
  -Name "nat-avd-prod-01" `
  -Location "eastus" `
  -PublicIpAddress $pip `
  -Sku Standard

# Associate NAT Gateway with your AVD Hosts Subnet

$vnet = Get-AzVirtualNetwork -ResourceGroupName "rg-avd-network" -Name "vnet-avd-prod-01"
$subnet = Get-AzVirtualNetworkSubnetConfig -Name "snet-avd-hosts" -VirtualNetwork $vnet
$subnet.NatGateway = $natGateway

Set-AzVirtualNetwork -VirtualNetwork $vnet