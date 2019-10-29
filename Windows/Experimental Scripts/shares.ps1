$shares = @()
Get-SmbShare | Select-Object -Property Name | ForEach-Object { $shares += $_.Name }  # creates a list of all shares on the computer
$allowedShares = "ADMIN$", "C$", "IPC$"  # default "good" shares
$extraShares = @()
# Compares the list of shares on the computer to the list of "good" shares and saves the result
Compare-Object -ReferenceObject $allowedShares -DifferenceObject $shares | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object  { $extraShares += $_.InputObject }

#  Deletes the SMB shares
foreach ($share in $extraShares) {
    Remove-SMbShare -Name $share
}
