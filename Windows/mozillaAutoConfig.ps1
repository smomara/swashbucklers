param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

$continue = Read-Host "Is Mozilla Firefox installed and updated? (y/n)"
if ($continue -eq "y") {
    Write-Host "Copying over the configuration files"
    Copy-Item -Path ".\Mozilla Firefox Hardening\autoconfig.js" -Destination "C:\Program Files\Mozilla Firefox\defaults\pref"
    Copy-Item -Path ".\Mozilla Firefox Hardening\firefox.cfg" -Destination "C:\Program Files\Mozilla Firefox"
    Write-Host "Configuration complete."
}
else {
    Write-Host "Please install Mozilla Firefox and run the script again."
}

Read-Host "Press any character to exit the script"
