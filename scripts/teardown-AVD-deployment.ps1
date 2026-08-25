<#
.SYNOPSIS
    Teardown Script: Removes all AVD project resource groups and assets.
.AUTHOR
    Ananda Mohite
#>

# Define target Resource Groups
$ResourceGroups = @(
    "rg-avd-compute",
    "rg-avd-management",
    "rg-avd-network",
    "rg-avd-storage" # Included if created during host pool/profile setup
)

foreach ($rg in $ResourceGroups) {
    if (Get-AzResourceGroup -Name $rg -ErrorAction SilentlyContinue) {
        Write-Host "Deleting Resource Group: $rg ..." -ForegroundColor Yellow
        Remove-AzResourceGroup -Name $rg -Force -AsJob
    } else {
        Write-Host "Resource Group $rg not found, skipping." -ForegroundColor Gray
    }
}

Write-Host "Deletion jobs submitted successfully. Resources will be removed in the background." -ForegroundColor Green