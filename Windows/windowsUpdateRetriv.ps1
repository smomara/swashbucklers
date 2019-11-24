param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

if (Test-Path ".\OutputInput\winUpdates.txt") {
    Remove-Item -Path ".\OutputInput\winUpdates.txt"
}
New-Item -Path .\OutputInput -ItemType File -Name "winUpdates.txt" > $null

Write-Host "Retrieving KB numbers of uninstalled updates"

$possibleUpdates = @()
Get-WindowsPackage -Online |
Where-Object { $_.PackageState -ne "Installed" -and $_.PackageName -match "KB" } | 
ForEach-Object { $possibleUpdates += $_.PackageName.Substring($_.PackageName.IndexOf("K"), 9) }

Add-Content -Path .\OutputInput\winUpdates.txt -Value $possibleUpdates
Write-Host "KB numbers of uninstalled updates added into winUpdates.txt"
Read-Host "Press enter to exit the script"