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
$Env:Path += "%SYSTEMROOT%\System32\LGPO" # Adds LGPO to the Path


$win_version = Get-WmiObject -class Win32_OperatingSystem
$OS = $win_version.caption -join $win_version.version
if ($OS -match "Server") { # Checks if the image is a Server image
    $pathToTemp = ".\Win10GPOTemplates\FinishedServer\{E57A3516-EC0A-4648-B108-C40B33EE4089}"
} else {
    $pathToTemp = ".\Win10GPOTemplates\FinishedWin10ENT\{E0EBFD8A-0E3D-4561-B427-10794DEB23C5}"
}

Write-Host "Applying configurations to $OS"
LGPO /g $pathToTemp

Write-Host "`n`nScript complete."
Read-Host "Press enter to exit the script"
