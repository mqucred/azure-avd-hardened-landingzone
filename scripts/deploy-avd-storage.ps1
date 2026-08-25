<#
.SYNOPSIS
    Phase 1: Deploys Premium FileStorage Account for FSLogix Profiles with Entra ID Kerberos Authentication.
.AUTHOR
    Ananda Mohite
#>


# 1. Parameters & Tags

$Location          = "eastus"
$RG_Storage        = "rg-avd-storage"
$StorageAccountName = "stavdfslogix" + (Get-Random -Minimum 1000 -Maximum 9999)
$ShareName         = "fslogix-profiles"

$Tags = @{
    "Environment"  = "Production"
    "WorkloadName" = "AVD-Enterprise-LandingZone"
    "Owner"        = "Ananda Mohite"
    "CostCenter"   = "CC-IT-AVD-01"
    "Criticality"  = "High"
}


# 2. Provision Resource Group

if (-not (Get-AzResourceGroup -Name $RG_Storage -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $RG_Storage -Location $Location -Tag $Tags | Out-Null
    Write-Host "Created Resource Group: $RG_Storage" -ForegroundColor Green
} else {
    Write-Host "Resource Group $RG_Storage already exists." -ForegroundColor Yellow
}


# 3. Deploy Premium File Storage Account

$StorageAccount = New-AzStorageAccount `
    -ResourceGroupName $RG_Storage `
    -Name $StorageAccountName `
    -Location $Location `
    -SkuName "Premium_LRS" `
    -Kind "FileStorage" `
    -EnableHttpsTrafficOnly $true `
    -Tag $Tags

Write-Host "Storage Account Created: $($StorageAccount.StorageAccountName)" -ForegroundColor Green

# 
# 4. Create FSLOGIX File Share
# 
$Context = $StorageAccount.Context
$FileShare = New-AzRmStorageShare `
    -ResourceGroupName $RG_Storage `
    -StorageAccountName $StorageAccountName `
    -Name $ShareName `
    -QuotaGiB 100

Write-Host "File Share '$ShareName' created with 100 GiB quota." -ForegroundColor Green


# 5. Enable Entra ID Kerberos Authentication For SMB

Set-AzStorageAccount `
    -ResourceGroupName $RG_Storage `
    -Name $StorageAccountName `
    -EnableAzureActiveDirectoryKerberosForFile $true


Write-Host "Entra ID Kerberos Authentication enabled on $($StorageAccountName)" -ForegroundColor Green

Set-AzStorageAccount -ResourceGroupName "rg-avd-storage" -Name "stavdfslogix8576" -EnableAzureActiveDirectoryKerberosForFile $true

# Output UNC Path for FSLogix Configuration

$UncPath = "\\$StorageAccountName.file.core.windows.net\$ShareName"
Write-Host "FSLogix UNC Target Path: $UncPath" -ForegroundColor Cyan






