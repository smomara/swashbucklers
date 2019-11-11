param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

Write-Host "Copying LGPO"
Copy-Item -Path .\Win10GPOTemplates\LGPO -Destination C:\Windows\System32

Write-Host "Applying the configurations."
Invoke-Command -ScriptBlock {"LGPO /g .\Win10GPOTemplates\FinishedWin10ENT\{E0EBFD8A-0E3D-4561-B427-10794DEB23C5}"}