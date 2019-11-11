param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

Write-Host "Copying LGPO"
if (Test-Path -Path C:\Windows\System32\LGPO) {
    Remove-Item -Path C:\Windows\System32\LGPO -Recurse
}
Copy-Item -Path .\Win10GPOTemplates\LGPO -Destination C:\Windows\System32 -Recurse
# Maybe add to Path env var

Write-Host "Applying the configurations."
# Invoke-Command -ScriptBlock {"LGPO /g .\Win10GPOTemplates\FinishedWin10ENT\{E0EBFD8A-0E3D-4561-B427-10794DEB23C5}"}
Import-GPO -BackupId E0EBFD8A-0E3D-4561-B427-10794DEB23C5 -Path ".\Win10GPOTemplates\FinishedWin10ENT\{E0EBFD8A-0E3D-4561-B427-10794DEB23C5}"

Write-Host "Script complete."
Read-Host "Press any character to exit the script"
