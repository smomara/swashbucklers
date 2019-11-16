param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

Write-Host "Copying LGPO"
if (Test-Path -Path C:\Windows\System32\LGPO) {
    Remove-Item -Path C:\Windows\System32\LGPO -Recurse -Force
}
Copy-Item -Path .\Win10GPOTemplates\LGPO -Destination C:\Windows\System32 -Recurse
# Maybe add to Path env var

Write-Host "Applying configurations"
LGPO /g '.\Win10GPOTemplates\FinishedWin10ENT\{E0EBFD8A-0E3D-4561-B427-10794DEB23C5}'

Write-Host "`n`nScript complete."
Read-Host "Press enter to exit the script"
