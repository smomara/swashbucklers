param(
        [Parameter()]
        [string]$OldPath
    )
Push-Location $OldPath

Write-Host "Applying registry configurations"
reg import ".\OutputInput\firewallconfig.reg"

Write-Host "Configurations complete"
Write-Host "Please check firewall inbound/outbound policies"
Start-Process wf.msc
Read-Host "Press enter to exit the script"