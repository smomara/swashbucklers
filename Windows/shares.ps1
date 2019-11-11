param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

$allowedShares = "ADMIN$", "C$", "IPC$"  # default "good" shares

$new = 'y'
while ($new -eq 'y') {
    $new = Read-Host "Do you want to whitelist a share? (y/n)"
    if ($new -eq 'y') {
        $allowedShares += Read-Host "Enter the share name exactly."
        Write-Host $allowedShares[-1]"has been whitelisted."
    }
}

$shares = @()
Get-SmbShare | Select-Object -Property Name | ForEach-Object { $shares += $_.Name }  # creates a list of all shares on the computer
$extraShares = @()
# Compares the list of shares on the computer to the list of "good" shares and saves the result
Compare-Object -ReferenceObject $allowedShares -DifferenceObject $shares | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object  { $extraShares += $_.InputObject }

Clear-Host
Write-Host "`nRemoving the following shares: $extraShares`n-----------------`n`n"

#  Deletes the SMB shares
foreach ($share in $extraShares) {
    # Remove-SmbShare -Name $share -Force
    Write-Host "Removed $share`n"
}

Write-Host "`n-----------------`n`nScript complete.`n`n"
Read-Host "Press any character to exit the script"
