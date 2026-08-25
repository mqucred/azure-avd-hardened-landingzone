<#
.SYNOPSIS
    Phase 2: Deploys AVD Control Plane (Host Pool, Application Group, and Workspace).
.AUTHOR
    Ananda Mohite
#>


# 1. Parameters & Tags

$Location          = "eastus"
$RG_Management     = "rg-avd-management"
$HostPoolName      = "hp-avd-pooled-01"
$AppGroupName      = "dag-avd-desktop-01"
$WorkspaceName     = "ws-avd-prod-01"

$Tags = @{
    "Environment"  = "Production"
    "WorkloadName" = "AVD-Enterprise-LandingZone"
    "Owner"        = "Ananda Mohite"
    "CostCenter"   = "CC-IT-AVD-01"
}

Register-AzResourceProvider -ProviderNamespace "Microsoft.DesktopVirtualization"

Get-AzResourceProvider -ProviderNamespace "Microsoft.DesktopVirtualization" | Select-Object ProviderNamespace, RegistrationState

# 2. Provison management Resource Group

if (-not (Get-AzResourceGroup -Name $RG_Management -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $RG_Management -Location $Location -Tag $Tags | Out-Null
    Write-Host "Created Resource Group: $RG_Management" -ForegroundColor Green
}


# 3. Deploy Host Pool (Pooled / Breadth-First / Preferred Desktop)

$HostPool = New-AzWvdHostPool `
    -ResourceGroupName $RG_Management `
    -Name $HostPoolName `
    -Location $Location `
    -HostPoolType "Pooled" `
    -LoadBalancerType "BreadthFirst" `
    -PreferredAppGroupType "Desktop" `
    -MaxSessionLimit 10 `
    -ValidationEnvironment:$false `
    -Tag $Tags

Write-Host "Host Pool created: $HostPoolName" -ForegroundColor Green


# 4. Deploy Desktop Application Group

$AppGroup = New-AzWvdApplicationGroup `
    -ResourceGroupName $RG_Management `
    -Name $AppGroupName `
    -Location $Location `
    -ApplicationGroupType "Desktop" `
    -HostPoolArmPath $HostPool.Id `
    -Tag $Tags

Write-Host "Desktop Application Group created: $AppGroupName" -ForegroundColor Green


# 5. Deploy Workspace & Register Application Group

$Workspace = New-AzWvdWorkspace `
    -ResourceGroupName $RG_Management `
    -Name $WorkspaceName `
    -Location $Location `
    -ApplicationGroupReference $AppGroup.Id `
    -Tag $Tags

Write-Host "Workspace created and linked: $WorkspaceName" -ForegroundColor Green
Write-Host "AVD Control Plane Deployment Complete!" -ForegroundColor Cyan



